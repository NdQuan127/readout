defmodule Readout.IngestionTest do
  use Readout.DataCase, async: true
  use Oban.Testing, repo: Readout.Repo

  alias Readout.{Accounts, Ingestion}
  alias Readout.Accounts.Scope
  alias Readout.Ingestion.{Article, ArticleContent, Source, SourceFetcher}
  alias Readout.Workers.{ArticleScrapeWorker, ArticleSummarizeWorker, SourceFetchWorker}

  test "subscription rejects an unreachable feed before storing it" do
    {:ok, user} = Accounts.register_user(%{email: "reader@example.com"})
    scope = Scope.for_user(user)

    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 404, "not found")
    end)

    assert {:error, {:feed_unreachable, 404}} =
             Ingestion.subscribe_source(scope, %{url: "https://example.com/missing.xml"})

    assert [] = all_enqueued(worker: SourceFetchWorker)
  end

  test "two users subscribing to the same URL share one Source and one pending fetch job" do
    stub_valid_feed()
    {:ok, first_user} = Accounts.register_user(%{email: "first@example.com"})
    {:ok, second_user} = Accounts.register_user(%{email: "second@example.com"})
    first_scope = Scope.for_user(first_user)
    second_scope = Scope.for_user(second_user)

    assert {:ok, first_source} =
             Ingestion.subscribe_source(first_scope, %{
               url: "https://example.com/feed.xml",
               name: "Example"
             })

    assert {:ok, second_source} =
             Ingestion.subscribe_source(second_scope, %{
               url: "https://example.com/feed.xml",
               name: "Another Name"
             })

    assert first_source.id == second_source.id

    assert [job] = all_enqueued(worker: SourceFetchWorker)
    assert job.args == %{"source_id" => first_source.id}
  end

  test "fetch worker stores visible articles once when retried" do
    stub_valid_feed()
    {:ok, user} = Accounts.register_user(%{email: "reader@example.com"})
    scope = Scope.for_user(user)

    {:ok, source} =
      Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml", name: "Example"})

    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, """
      <rss version="2.0">
        <channel>
          <item>
            <title>Reliable Jobs</title>
            <link>https://example.com/reliable-jobs</link>
            <pubDate>Tue, 09 Jun 2026 08:30:00 GMT</pubDate>
          </item>
        </channel>
      </rss>
      """)
    end)

    assert :ok = perform_job(SourceFetchWorker, %{source_id: source.id})
    assert :ok = perform_job(SourceFetchWorker, %{source_id: source.id})

    assert [
             %{
               title: "Reliable Jobs",
               canonical_url: "https://example.com/reliable-jobs",
               published_at: ~U[2026-06-09 08:30:00Z]
             }
           ] =
             Ingestion.list_articles(scope)
  end

  test "source fetcher enqueues scrape only for newly inserted Articles" do
    source = Repo.insert!(%Source{canonical_url: "https://example.com/feed.xml", name: "Example"})
    source_id = source.id
    Phoenix.PubSub.subscribe(Readout.PubSub, "source:#{source_id}:fetched")

    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, """
      <rss version="2.0">
        <channel>
          <item>
            <title>First new article</title>
            <link>https://example.com/first-new-article</link>
            <pubDate>Tue, 09 Jun 2026 08:30:00 GMT</pubDate>
          </item>
          <item>
            <title>Second new article</title>
            <link>https://example.com/second-new-article</link>
            <pubDate>Tue, 09 Jun 2026 09:30:00 GMT</pubDate>
          </item>
        </channel>
      </rss>
      """)
    end)

    assert {:ok, inserted_article_ids} = SourceFetcher.run(source.id)
    assert_receive {:articles_fetched, ^source_id}

    articles = Repo.all(from article in Article, where: article.source_id == ^source.id)
    article_ids = Enum.map(articles, & &1.id)

    assert Enum.sort(inserted_article_ids) == Enum.sort(article_ids)

    for article <- articles do
      assert_enqueued(worker: ArticleScrapeWorker, args: %{article_id: article.id})
    end

    Repo.delete_all(Oban.Job)

    assert {:ok, []} = SourceFetcher.run(source.id)
    assert [] = all_enqueued(worker: ArticleScrapeWorker)
  end

  test "scrape worker stores Content from paragraphs and enqueues summary" do
    stub_valid_feed()
    {:ok, user} = Accounts.register_user(%{email: "reader@example.com"})
    scope = Scope.for_user(user)
    {:ok, source} = Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml"})

    article =
      Repo.insert!(%Article{
        source_id: source.id,
        canonical_url: "https://example.com/article",
        title: "Article"
      })

    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, """
      <html>
        <body>
          <h1>Ignore heading</h1>
          <p>First paragraph.</p>
          <p>Second paragraph.</p>
        </body>
      </html>
      """)
    end)

    assert :ok = perform_job(ArticleScrapeWorker, %{article_id: article.id})

    assert %ArticleContent{text: "First paragraph.\n\nSecond paragraph."} =
             Repo.get_by(ArticleContent, article_id: article.id)

    assert_enqueued(worker: ArticleSummarizeWorker, args: %{article_id: article.id})
  end

  test "subscription rejects content that is not an RSS or Atom document" do
    {:ok, user} = Accounts.register_user(%{email: "reader@example.com"})
    scope = Scope.for_user(user)

    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, "<html><body>Not a feed</body></html>")
    end)

    assert {:error, :invalid_rss_format} =
             Ingestion.subscribe_source(scope, %{url: "https://example.com/page"})
  end

  test "a User scope only lists that User's Sources" do
    stub_valid_feed()
    {:ok, first_user} = Accounts.register_user(%{email: "first@example.com"})
    {:ok, second_user} = Accounts.register_user(%{email: "second@example.com"})
    first_scope = Scope.for_user(first_user)
    second_scope = Scope.for_user(second_user)

    {:ok, source} =
      Ingestion.subscribe_source(first_scope, %{
        url: "https://example.com/first-feed.xml",
        name: "First"
      })

    assert [source] == Ingestion.list_sources(first_scope)
    assert [] == Ingestion.list_sources(second_scope)
  end

  defp stub_valid_feed do
    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, "<rss><channel></channel></rss>")
    end)
  end
end
