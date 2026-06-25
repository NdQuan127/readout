defmodule Readout.Workers.SourceFetchWorker do
  use Oban.Worker,
    queue: :source_fetch,
    max_attempts: 5,
    unique: [period: 60, fields: [:worker, :args], keys: [:source_id]]

  alias Readout.Ingestion.SourceFetcher

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"source_id" => source_id}}) do
    case SourceFetcher.run(source_id) do
      {:ok, _inserted_article_ids} ->
        :ok

      {:error, {:http_status, status}} when status in 400..499 ->
        {:cancel, "HTTP #{status}"}

      {:cancel, reason} ->
        {:cancel, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
