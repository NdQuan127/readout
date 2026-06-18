defmodule Readout.Ingestion do
  import Ecto.Query

  alias Ecto.Multi
  alias Readout.Accounts.Scope
  alias Readout.HTTP
  alias Readout.Ingestion.{Article, ArticleContent, FeedParser, Source, UserSource}
  alias Readout.Repo
  alias Readout.Workers.{ArticleScrapeWorker, ArticleSummarizeWorker, SourceFetchWorker}

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

  def get_article(article_id) do
    Article
    |> Repo.get(article_id)
    |> Repo.preload([:content, :summary])
  end

  def enqueue_article_scrape(article_id) do
    %{article_id: article_id}
    |> ArticleScrapeWorker.new()
    |> Oban.insert()
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
        |> Floki.find("p")
        |> Enum.map(fn paragraph -> paragraph |> Floki.text() |> String.trim() end)
        |> Enum.reject(&(&1 == ""))
        |> Enum.join("\n\n")

      if content == "" do
        {:error, :content_not_found}
      else
        {:ok, content}
      end
    end
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
