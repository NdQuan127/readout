defmodule Readout.Workers.ArticleSummarizeWorker do
  use Oban.Worker,
    queue: :article_summarize,
    max_attempts: 5,
    unique: [period: 300, fields: [:worker, :args], keys: [:article_id]]

  alias Readout.Analysis

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"article_id" => article_id}}) do
    case Analysis.summarize_article(article_id) do
      {:ok, _summary} ->
        :ok

      {:cancel, reason} ->
        {:cancel, reason}

      {:error, {:http_status, status}} when status in [429] or status in 500..599 ->
        {:error, {:http_status, status}}

      {:error, {:http_status, status}} ->
        {:cancel, "HTTP #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
