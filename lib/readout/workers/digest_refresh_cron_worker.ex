defmodule Readout.Workers.DigestRefreshCronWorker do
  use Oban.Worker,
    queue: :digest_refresh,
    max_attempts: 3

  import Ecto.Query

  alias Readout.Accounts.User
  alias Readout.Ingestion.UserSource
  alias Readout.Repo
  alias Readout.Workers.DigestRefreshWorker

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    User
    |> join(:inner, [user], user_source in UserSource, on: user_source.user_id == user.id)
    |> distinct(true)
    |> select([user, _user_source], user.id)
    |> Repo.all()
    |> Enum.reduce_while(:ok, fn user_id, :ok ->
      case Oban.insert(DigestRefreshWorker.new(%{user_id: user_id})) do
        {:ok, _job} -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end
end
