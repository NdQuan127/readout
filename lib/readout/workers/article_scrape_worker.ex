defmodule Readout.Workers.ArticleScrapeWorker do
  use Oban.Worker,
    queue: :article_scrape,
    max_attempts: 5,
    unique: [period: 300, fields: [:worker, :args], keys: [:article_id]]

  alias Readout.Ingestion

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"article_id" => article_id}}) do
    case Ingestion.scrape_article(article_id) do
      {:ok, _content} ->
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
