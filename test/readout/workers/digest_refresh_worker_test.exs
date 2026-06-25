defmodule Readout.Workers.DigestRefreshWorkerTest do
  use Readout.DataCase, async: true
  use Oban.Testing, repo: Readout.Repo

  alias Readout.AccountsFixtures
  alias Readout.Analysis.ArticleSummary
  alias Readout.Curation.Digest
  alias Readout.Ingestion.{Article, Source, UserSource}
  alias Readout.Workers.DigestRefreshWorker

  test "refreshes today's Digest for the requested User" do
    user = AccountsFixtures.user_fixture()
    today = Date.utc_today()
    summary = summary_fixture(user, inserted_at: at_noon(today))

    assert :ok = perform_job(DigestRefreshWorker, %{user_id: user.id})

    digest = Repo.get_by!(Digest, user_id: user.id, date: today) |> Repo.preload(:items)
    assert Enum.map(digest.items, & &1.summary_id) == [summary.id]
  end

  defp summary_fixture(user, attrs) do
    source =
      Repo.insert!(%Source{
        canonical_url: unique_url(),
        name: "Source #{System.unique_integer([:positive])}"
      })

    Repo.insert!(%UserSource{user_id: user.id, source_id: source.id})

    article =
      Repo.insert!(%Article{
        source_id: source.id,
        canonical_url: unique_url(),
        title: attrs[:title] || "Article #{System.unique_integer([:positive])}",
        published_at: attrs[:published_at] || at_noon(Date.utc_today())
      })

    Repo.insert!(%ArticleSummary{
      article_id: article.id,
      summary_text: attrs[:summary_text] || "Summary #{System.unique_integer([:positive])}",
      tags: attrs[:tags] || ["technology"],
      inserted_at: attrs[:inserted_at] || DateTime.utc_now(:second),
      updated_at: attrs[:inserted_at] || DateTime.utc_now(:second)
    })
  end

  defp at_noon(date) do
    DateTime.new!(date, ~T[12:00:00], "Etc/UTC") |> DateTime.truncate(:second)
  end

  defp unique_url do
    "https://example#{System.unique_integer([:positive])}.com/feed.xml"
  end
end
