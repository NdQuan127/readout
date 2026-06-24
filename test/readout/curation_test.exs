defmodule Readout.CurationTest do
  use Readout.DataCase, async: true

  alias Readout.AccountsFixtures
  alias Readout.Curation
  alias Readout.Curation.{Digest, DigestItem}
  alias Readout.Analysis.ArticleSummary
  alias Readout.Ingestion.{Article, Source, UserSource}

  describe "generate_digest/2" do
    test "selects today's summaries from subscribed Sources only" do
      scope = AccountsFixtures.user_scope_fixture()
      today = Date.utc_today()
      yesterday = Date.add(today, -1)

      included =
        summary_fixture(scope, inserted_at: at_noon(today), published_at: at_hour(today, 9))

      backdated =
        summary_fixture(scope, inserted_at: at_noon(yesterday), published_at: at_hour(today, 10))

      unsubscribed =
        summary_fixture(inserted_at: at_noon(today), published_at: at_hour(today, 11))

      assert {:ok, digest} = Curation.generate_digest(scope, today)

      summary_ids = Enum.map(digest.items, & &1.summary_id)
      assert summary_ids == [included.id]
      refute backdated.id in summary_ids
      refute unsubscribed.id in summary_ids
    end

    test "is idempotent for today's digest" do
      scope = AccountsFixtures.user_scope_fixture()
      today = Date.utc_today()
      summary = summary_fixture(scope, inserted_at: at_noon(today))

      assert {:ok, _digest} = Curation.generate_digest(scope, today)
      assert {:ok, digest} = Curation.generate_digest(scope, today)

      assert Repo.aggregate(Digest, :count) == 1
      assert Repo.aggregate(DigestItem, :count) == 1
      assert Enum.map(digest.items, & &1.summary_id) == [summary.id]
    end

    test "does not create or update digests for past dates" do
      scope = AccountsFixtures.user_scope_fixture()
      yesterday = Date.utc_today() |> Date.add(-1)
      summary_fixture(scope, inserted_at: at_noon(yesterday))

      assert {:ok, nil} = Curation.generate_digest(scope, yesterday)

      assert Repo.aggregate(Digest, :count) == 0
      assert Repo.aggregate(DigestItem, :count) == 0
    end

    test "creates an empty digest for today when no summaries match" do
      scope = AccountsFixtures.user_scope_fixture()
      today = Date.utc_today()

      assert {:ok, digest} = Curation.generate_digest(scope, today)

      assert digest.user_id == scope.user.id
      assert digest.date == today
      assert digest.items == []
    end
  end

  defp summary_fixture(attrs) do
    summary_fixture(nil, attrs)
  end

  defp summary_fixture(scope, attrs) do
    source = source_fixture()

    if scope do
      Repo.insert!(%UserSource{user_id: scope.user.id, source_id: source.id})
    end

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

  defp source_fixture do
    Repo.insert!(%Source{
      canonical_url: unique_url(),
      name: "Source #{System.unique_integer([:positive])}"
    })
  end

  defp at_noon(date), do: at_hour(date, 12)

  defp at_hour(date, hour) do
    DateTime.new!(date, Time.new!(hour, 0, 0), "Etc/UTC") |> DateTime.truncate(:second)
  end

  defp unique_url do
    "https://example#{System.unique_integer([:positive])}.com/feed.xml"
  end
end
