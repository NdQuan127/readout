defmodule Readout.Ingestion do
  import Ecto.Query

  alias Ecto.Multi
  alias Readout.Accounts.Scope
  alias Readout.Analysis.ArticleSummary
  alias Readout.HTTP
  alias Readout.Ingestion.{Article, ArticleContent, FeedParser, Source, UserSource}
  alias Readout.Repo
  alias Readout.Workers.{ArticleScrapeWorker, ArticleSummarizeWorker, SourceFetchWorker}

  @content_root_selectors [
    "article",
    "main",
    "[role=\"main\"]",
    ".entry-content",
    ".post-content",
    ".article-content",
    ".article-body",
    ".post-body",
    ".e-content",
    ".h-entry",
    ".hentry",
    "#content"
  ]

  @noise_selectors [
    "script",
    "style",
    "noscript",
    "template",
    "svg",
    "nav",
    "header",
    "footer",
    "aside",
    "form",
    "button",
    "iframe",
    "[role=\"navigation\"]",
    "[aria-hidden=\"true\"]",
    ".related",
    ".related-posts",
    ".comments",
    ".comment",
    ".newsletter",
    ".subscribe",
    ".subscription",
    ".share",
    ".sharing",
    ".sidebar",
    ".ad",
    ".ads",
    ".advertisement",
    ".promo"
  ]

  def subscribe_source(%Scope{user: user}, attrs) do
    with {:ok, canonical_url} <- canonicalize_url(attrs[:url] || attrs["url"]),
         :ok <- validate_feed(canonical_url) do
      source_attrs = %{
        canonical_url: canonical_url,
        name: attrs[:name] || attrs["name"] || URI.parse(canonical_url).host
      }

      Multi.new()
      |> Multi.run(:source, fn repo, _changes -> find_or_create_source(repo, source_attrs) end)
      |> Multi.insert(
        :subscription,
        fn %{source: source} ->
          UserSource.changeset(%UserSource{}, %{user_id: user.id, source_id: source.id})
        end,
        on_conflict: :nothing,
        conflict_target: [:user_id, :source_id]
      )
      |> Oban.insert(:job, fn %{source: source} ->
        SourceFetchWorker.new(%{source_id: source.id})
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{source: source}} -> {:ok, source}
        {:error, _operation, reason, _changes} -> {:error, reason}
      end
    end
  end

  def list_articles(%Scope{user: %{id: user_id}}) do
    from(article in Article,
      join: user_source in UserSource,
      on: user_source.source_id == article.source_id,
      where: user_source.user_id == ^user_id,
      order_by: [desc: article.published_at, desc: article.inserted_at]
    )
    |> limit(20)
    |> preload([:content, :summary])
    |> Repo.all()
  end

  def list_sources(%Scope{user: %{id: user_id}}) do
    from(source in Source,
      join: user_source in UserSource,
      on: user_source.source_id == source.id,
      where: user_source.user_id == ^user_id,
      order_by: [asc: source.name]
    )
    |> Repo.all()
  end

  def list_source_management_entries(%Scope{user: %{id: user_id}}) do
    from(source in Source,
      join: user_source in UserSource,
      on: user_source.source_id == source.id,
      left_join: article in Article,
      on: article.source_id == source.id,
      left_join: summary in ArticleSummary,
      on: summary.article_id == article.id,
      where: user_source.user_id == ^user_id,
      group_by: source.id,
      order_by: [asc: source.name],
      select: %{
        id: source.id,
        name: source.name,
        canonical_url: source.canonical_url,
        article_count: count(article.id, :distinct),
        summary_count: count(summary.id, :distinct)
      }
    )
    |> Repo.all()
    |> Enum.map(&Map.put(&1, :status, source_status(&1)))
  end

  def get_article(%Scope{user: %{id: user_id}}, article_id) do
    with {:ok, article_id} <- Ecto.UUID.cast(article_id) do
      from(article in Article,
        join: user_source in UserSource,
        on: user_source.source_id == article.source_id,
        where: user_source.user_id == ^user_id and article.id == ^article_id
      )
      |> preload([:content, :summary])
      |> Repo.one()
    else
      :error -> nil
    end
  end

  def enqueue_article_scrape(%Scope{} = scope, article_id) do
    case get_article(scope, article_id) do
      nil -> {:error, :not_found}
      _article -> %{article_id: article_id} |> ArticleScrapeWorker.new() |> Oban.insert()
    end
  end

  def get_article_for_processing(article_id) do
    with {:ok, article_id} <- Ecto.UUID.cast(article_id) do
      Article
      |> Repo.get(article_id)
      |> Repo.preload([:content, :summary])
    else
      :error -> nil
    end
  end

  def scrape_article(article_id) do
    case Repo.get(Article, article_id) do
      nil ->
        {:cancel, "Article not found"}

      article ->
        with {:ok, document} <- HTTP.get(article.canonical_url),
             {:ok, text} <- extract_content(document) do
          Multi.new()
          |> Multi.insert(
            :content,
            ArticleContent.changeset(%ArticleContent{}, %{article_id: article.id, text: text}),
            on_conflict: [set: [text: text, updated_at: now()]],
            conflict_target: :article_id,
            returning: true
          )
          |> Oban.insert(:summary_job, ArticleSummarizeWorker.new(%{article_id: article.id}))
          |> Repo.transaction()
          |> case do
            {:ok, %{content: content}} ->
              broadcast_scraped(article)
              {:ok, content}

            {:error, _operation, reason, _changes} ->
              {:error, reason}
          end
        end
    end
  end

  def list_articles(%Scope{user: %{id: user_id}}, source_id) do
    from(article in Article,
      join: user_source in UserSource,
      on: user_source.source_id == article.source_id,
      where: user_source.user_id == ^user_id and article.source_id == ^source_id,
      order_by: [desc: article.published_at, desc: article.inserted_at]
    )
    |> preload([:content, :summary])
    |> Repo.all()
  end

  defp source_status(%{article_count: 0}), do: "Fetching articles"

  defp source_status(%{article_count: article_count, summary_count: summary_count})
       when article_count == summary_count,
       do: "Summaries ready"

  defp source_status(%{article_count: article_count}) when article_count > 0, do: "Articles found"
  defp source_status(_entry), do: "Needs attention"

  defp validate_feed(url) do
    with {:ok, document} <- HTTP.get(url),
         {:ok, _entries} <- FeedParser.parse(document) do
      :ok
    else
      {:error, {:http_status, status}} -> {:error, {:feed_unreachable, status}}
      {:error, %_exception{}} -> {:error, :feed_unreachable}
      {:error, :invalid_rss_format} -> {:error, :invalid_rss_format}
    end
  end

  defp find_or_create_source(repo, attrs) do
    %Source{}
    |> Source.changeset(attrs)
    |> repo.insert(
      on_conflict: [set: [canonical_url: attrs.canonical_url]],
      conflict_target: :canonical_url,
      returning: true
    )
  end

  defp extract_content(document) do
    with {:ok, html} <- Floki.parse_document(document) do
      content =
        html
        |> prune_noise()
        |> content_root()
        |> paragraph_text()

      if content == "" do
        {:error, :content_not_found}
      else
        {:ok, content}
      end
    end
  end

  defp prune_noise(html) do
    Enum.reduce(@noise_selectors, html, fn selector, tree ->
      Floki.filter_out(tree, selector)
    end)
  end

  defp content_root(html) do
    candidates =
      @content_root_selectors
      |> Enum.flat_map(&Floki.find(html, &1))
      |> Enum.uniq()

    case candidates do
      [] -> html
      candidates -> Enum.max_by(candidates, &content_score/1)
    end
  end

  defp content_score(root) do
    paragraphs = Floki.find(root, "p")
    paragraph_count = length(paragraphs)
    text_length = root |> Floki.text() |> String.trim() |> String.length()

    paragraph_count * 1_000 + text_length
  end

  defp paragraph_text(root) do
    root
    |> Floki.find("p")
    |> Enum.map(fn paragraph -> paragraph |> Floki.text() |> normalize_text() end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  defp normalize_text(text) do
    text
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp broadcast_scraped(article) do
    Phoenix.PubSub.broadcast(
      Readout.PubSub,
      "source:#{article.source_id}:scraped",
      {:article_scraped, article.id}
    )
  end

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)

  defp canonicalize_url(url) when is_binary(url) do
    uri = URI.parse(String.trim(url))

    if uri.scheme in ["http", "https"] and is_binary(uri.host) do
      {:ok, URI.to_string(%{uri | fragment: nil, host: String.downcase(uri.host)})}
    else
      {:error, :invalid_source_url}
    end
  end

  defp canonicalize_url(_url), do: {:error, :invalid_source_url}
end
