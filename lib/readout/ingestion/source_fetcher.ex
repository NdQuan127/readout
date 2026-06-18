defmodule Readout.Ingestion.SourceFetcher do
  alias Readout.HTTP
  alias Readout.Ingestion.{Article, FeedParser, Source}
  alias Readout.Repo

  def run(source_id) do
    case Repo.get(Source, source_id) do
      nil -> {:cancel, "Source not found"}
      source -> fetch(source)
    end
  end

  defp fetch(source) do
    with {:ok, document} <- HTTP.get(source.canonical_url),
         {:ok, entries} <- FeedParser.parse(document) do
      {count, _rows} =
        entries
        |> Enum.map(&article_attrs(source, &1))
        |> then(
          &Repo.insert_all(Article, &1,
            on_conflict: :nothing,
            conflict_target: [:source_id, :canonical_url]
          )
        )

      Phoenix.PubSub.broadcast(
        Readout.PubSub,
        "source:#{source.id}:fetched",
        {:articles_fetched, source.id}
      )

      {:ok, count}
    end
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
