defmodule Readout.Workers.SourceFetchCronWorker do
  use Oban.Worker,
    queue: :source_fetch,
    max_attempts: 3

  import Ecto.Query

  alias Readout.Ingestion.Source
  alias Readout.Repo
  alias Readout.Workers.SourceFetchWorker

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Source
    |> select([source], source.id)
    |> Repo.all()
    |> Enum.reduce_while(:ok, fn source_id, :ok ->
      case Oban.insert(SourceFetchWorker.new(%{source_id: source_id})) do
        {:ok, _job} -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end
end
