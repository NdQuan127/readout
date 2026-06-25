defmodule Readout.Workers.DigestRefreshCronWorkerTest do
  use Readout.DataCase, async: true
  use Oban.Testing, repo: Readout.Repo

  alias Readout.AccountsFixtures
  alias Readout.Ingestion.{Source, UserSource}
  alias Readout.Workers.{DigestRefreshCronWorker, DigestRefreshWorker}

  test "enqueues one digest refresh job for each User with Sources" do
    user_a = AccountsFixtures.user_fixture()
    user_b = AccountsFixtures.user_fixture()
    user_without_sources = AccountsFixtures.user_fixture()

    subscribe_user_to_source!(user_a, "https://example.com/a.xml")
    subscribe_user_to_source!(user_a, "https://example.com/a-second.xml")
    subscribe_user_to_source!(user_b, "https://example.com/b.xml")

    assert :ok = perform_job(DigestRefreshCronWorker, %{})

    enqueued_user_ids =
      all_enqueued(worker: DigestRefreshWorker)
      |> Enum.map(& &1.args["user_id"])
      |> Enum.sort()

    assert enqueued_user_ids == Enum.sort([user_a.id, user_b.id])
    assert_enqueued(worker: DigestRefreshWorker, args: %{user_id: user_a.id})
    assert_enqueued(worker: DigestRefreshWorker, args: %{user_id: user_b.id})
    refute_enqueued(worker: DigestRefreshWorker, args: %{user_id: user_without_sources.id})
  end

  defp subscribe_user_to_source!(user, url) do
    source =
      Repo.insert!(%Source{
        canonical_url: url,
        name: URI.parse(url).host
      })

    Repo.insert!(%UserSource{user_id: user.id, source_id: source.id})
  end
end
