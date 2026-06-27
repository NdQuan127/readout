defmodule Readout.CurationTest do
  use Readout.DataCase, async: true

  import Readout.CurationFixtures

  alias Readout.AccountsFixtures
  alias Readout.Curation
  alias Readout.Curation.{Digest, DigestItem}

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

  defp at_noon(date), do: at_hour(date, 12)

  defp at_hour(date, hour) do
    DateTime.new!(date, Time.new!(hour, 0, 0), "Etc/UTC") |> DateTime.truncate(:second)
  end
end
