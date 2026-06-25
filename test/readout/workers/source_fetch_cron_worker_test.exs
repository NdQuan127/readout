defmodule Readout.Workers.SourceFetchCronWorkerTest do
  use Readout.DataCase, async: true
  use Oban.Testing, repo: Readout.Repo

  alias Readout.Ingestion.Source
  alias Readout.Workers.{SourceFetchCronWorker, SourceFetchWorker}

  test "enqueues one fetch job for each Source" do
    first = insert_source!("https://example.com/first.xml")
    second = insert_source!("https://example.com/second.xml")

    assert :ok = perform_job(SourceFetchCronWorker, %{})

    enqueued_source_ids =
      all_enqueued(worker: SourceFetchWorker)
      |> Enum.map(& &1.args["source_id"])
      |> Enum.sort()

    assert enqueued_source_ids == Enum.sort([first.id, second.id])
  end

  defp insert_source!(url) do
    Repo.insert!(%Source{canonical_url: url, name: URI.parse(url).host})
  end
end
