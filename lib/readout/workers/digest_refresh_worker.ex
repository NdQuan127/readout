defmodule Readout.Workers.DigestRefreshWorker do
  use Oban.Worker,
    queue: :digest_refresh,
    max_attempts: 3,
    unique: [period: 60, fields: [:worker, :args], keys: [:user_id]]

  alias Readout.Accounts.Scope
  alias Readout.Accounts.User
  alias Readout.Curation
  alias Readout.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    case Repo.get(User, user_id) do
      nil ->
        {:cancel, "User not found"}

      user ->
        {:ok, _digest} = Curation.generate_digest(Scope.for_user(user), Date.utc_today())
        :ok
    end
  end
end
