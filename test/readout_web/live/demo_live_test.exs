defmodule ReadoutWeb.DemoLiveTest do
  use ReadoutWeb.ConnCase, async: true
  use Oban.Testing, repo: Readout.Repo

  import Phoenix.LiveViewTest

  alias Readout.{Ingestion, Repo}
  alias Readout.Analysis.ArticleSummary
  alias Readout.Ingestion.{Article, ArticleContent}
  alias Readout.Workers.ArticleScrapeWorker

  test "redirects anonymous users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/demo")
  end

  describe "authenticated operator" do
    setup :register_and_log_in_user

    test "mount shows the logged-in user and their Sources", %{
      conn: conn,
      user: user,
      scope: scope
    } do
      stub_valid_feed()
      {:ok, source} = Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml"})

      {:ok, _view, html} = live(conn, ~p"/demo")

      assert html =~ "Readout"
      assert html =~ user.email
      assert html =~ source.name
    end

    test "subscription displays an invalid URL error", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/demo")

      view
      |> form("form", source: %{url: "not-a-url"})
      |> render_submit()

      assert has_element?(view, "#source-url-error", "Enter a valid HTTP or HTTPS URL.")
    end

    test "a fetch notification prepends a new Article without reloading", %{
      conn: conn,
      scope: scope
    } do
      stub_valid_feed()
      {:ok, source} = Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml"})
      {:ok, view, _html} = live(conn, ~p"/demo")

      Repo.insert!(%Article{
        source_id: source.id,
        canonical_url: "https://example.com/live-article",
        title: "Live article"
      })

      Phoenix.PubSub.broadcast(
        Readout.PubSub,
        "source:#{source.id}:fetched",
        {:articles_fetched, source.id}
      )

      assert render(view) =~ "Live article"
    end

    test "summarize button enqueues scrape for the article", %{conn: conn, scope: scope} do
      stub_valid_feed()
      {:ok, source} = Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml"})

      article =
        Repo.insert!(%Article{
          source_id: source.id,
          canonical_url: "https://example.com/article",
          title: "Article"
        })

      {:ok, view, _html} = live(conn, ~p"/demo")

      view
      |> element("#articles-#{article.id} button", "Tóm tắt")
      |> render_click()

      assert_enqueued(worker: ArticleScrapeWorker, args: %{article_id: article.id})
      assert render(view) =~ "Đang xử lý"
    end

    test "summarize ignores articles outside the logged-in user's scope", %{conn: conn} do
      other_scope = Readout.AccountsFixtures.user_scope_fixture()

      stub_valid_feed()

      {:ok, source} =
        Ingestion.subscribe_source(other_scope, %{url: "https://example.com/feed.xml"})

      article =
        Repo.insert!(%Article{
          source_id: source.id,
          canonical_url: "https://example.com/other-user-article",
          title: "Other user article"
        })

      {:ok, view, _html} = live(conn, ~p"/demo")

      render_click(view, :summarize, %{"id" => article.id})

      refute_enqueued(worker: ArticleScrapeWorker, args: %{article_id: article.id})
    end

    test "scrape notification renders Content state without reloading", %{
      conn: conn,
      scope: scope
    } do
      stub_valid_feed()
      {:ok, source} = Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml"})

      article =
        Repo.insert!(%Article{
          source_id: source.id,
          canonical_url: "https://example.com/article",
          title: "Article"
        })

      {:ok, view, _html} = live(conn, ~p"/demo")

      Repo.insert!(%ArticleContent{article_id: article.id, text: "Already scraped"})

      Phoenix.PubSub.broadcast(
        Readout.PubSub,
        "source:#{source.id}:scraped",
        {:article_scraped, article.id}
      )

      assert render(view) =~ "Đã cào 15 ký tự"
    end

    test "summary notification renders Summary and Tags without reloading", %{
      conn: conn,
      scope: scope
    } do
      stub_valid_feed()
      {:ok, source} = Ingestion.subscribe_source(scope, %{url: "https://example.com/feed.xml"})

      article =
        Repo.insert!(%Article{
          source_id: source.id,
          canonical_url: "https://example.com/article",
          title: "Article"
        })

      {:ok, view, _html} = live(conn, ~p"/demo")

      Repo.insert!(%ArticleSummary{
        article_id: article.id,
        summary_text: "Bản tóm tắt hiển thị ngay.",
        tags: ["ai", "technology"]
      })

      Phoenix.PubSub.broadcast(
        Readout.PubSub,
        "source:#{source.id}:summarized",
        {:article_summarized, article.id}
      )

      assert render(view) =~ "Bản tóm tắt hiển thị ngay."
      assert render(view) =~ "technology"
    end
  end

  defp stub_valid_feed do
    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, "<rss><channel></channel></rss>")
    end)
  end
end
