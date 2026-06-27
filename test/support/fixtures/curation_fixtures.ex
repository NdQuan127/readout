defmodule Readout.CurationFixtures do
  @moduledoc """
  Test fixtures for the Curation context.

  Builds Summary records (with their Article + Source) for a user in scope, so a
  generated Digest has something to gather. Supports many Summaries across many
  Sources by passing a shared `:source` — handy for exercising the Source filter.
  """

  alias Readout.Analysis.ArticleSummary
  alias Readout.Ingestion.{Article, Source, UserSource}
  alias Readout.Repo

  @doc """
  Inserts a Source.
  """
  def source_fixture(attrs \\ []) do
    Repo.insert!(%Source{
      canonical_url: attrs[:canonical_url] || unique_url(),
      name: attrs[:name] || "Source #{System.unique_integer([:positive])}"
    })
  end

  @doc """
  Inserts a Summary (plus its Article and Source).

  With a `scope`, the Source is also subscribed for that user so the Summary is
  eligible for the user's Digest. Pass `source: source_fixture()` to place several
  Summaries under the same Source.
  """
  def summary_fixture(attrs) when is_list(attrs), do: summary_fixture(nil, attrs)

  def summary_fixture(scope, attrs) do
    source = attrs[:source] || source_fixture()

    if scope do
      Repo.insert!(%UserSource{user_id: scope.user.id, source_id: source.id},
        on_conflict: :nothing,
        conflict_target: [:user_id, :source_id]
      )
    end

    article =
      Repo.insert!(%Article{
        source_id: source.id,
        canonical_url: unique_url(),
        title: attrs[:title] || "Article #{System.unique_integer([:positive])}",
        published_at: attrs[:published_at] || DateTime.utc_now(:second)
      })

    %ArticleSummary{
      article_id: article.id,
      summary_text: attrs[:summary_text] || "Summary #{System.unique_integer([:positive])}",
      tags: attrs[:tags] || ["technology"],
      inserted_at: attrs[:inserted_at] || DateTime.utc_now(:second),
      updated_at: attrs[:inserted_at] || DateTime.utc_now(:second)
    }
    |> Repo.insert!()
    |> Repo.preload(article: :source)
  end

  defp unique_url do
    "https://example#{System.unique_integer([:positive])}.com/feed.xml"
  end
end
