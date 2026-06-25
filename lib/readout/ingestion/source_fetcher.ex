defmodule Readout.Ingestion.SourceFetcher do
  alias Readout.HTTP
  alias Readout.Ingestion.{Article, FeedParser, Source}
  alias Readout.Repo
  alias Readout.Workers.ArticleScrapeWorker

  def run(source_id) do
    case Repo.get(Source, source_id) do
      nil -> {:cancel, "Source not found"}
      source -> fetch(source)
    end
  end

  defp fetch(source) do
    with {:ok, document} <- HTTP.get(source.canonical_url),
         {:ok, entries} <- FeedParser.parse(document),
         {:ok, inserted_article_ids} <- insert_articles_and_enqueue_scrapes(source, entries) do
      Phoenix.PubSub.broadcast(
        Readout.PubSub,
        "source:#{source.id}:fetched",
        {:articles_fetched, source.id}
      )

      {:ok, inserted_article_ids}
    end
  end

  defp insert_articles_and_enqueue_scrapes(source, entries) do
    Repo.transaction(fn ->
      inserted_article_ids =
        entries
        |> Enum.map(&article_attrs(source, &1))
        |> insert_new_articles()

      Enum.each(inserted_article_ids, fn article_id ->
        case Oban.insert(ArticleScrapeWorker.new(%{article_id: article_id})) do
          {:ok, _job} -> :ok
          {:error, reason} -> Repo.rollback(reason)
        end
      end)

      inserted_article_ids
    end)
  end

  defp insert_new_articles([]), do: []

  defp insert_new_articles(attrs) do
    {_count, rows} =
      Repo.insert_all(Article, attrs,
        on_conflict: :nothing,
        conflict_target: [:source_id, :canonical_url],
        returning: [:id]
      )

    Enum.map(rows, & &1.id)
  end

  defp article_attrs(source, entry) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      id: Ecto.UUID.generate(),
      source_id: source.id,
      canonical_url: entry.url,
      title: entry.title,
      published_at: entry.published_at,
      inserted_at: now,
      updated_at: now
    }
  end
end
