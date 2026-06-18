defmodule Readout.Accounts do
  alias Readout.Accounts.User
  alias Readout.Repo

  @demo_email "demo@readout.local"

  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_demo_user do
    case Repo.get_by(User, email: @demo_email) do
      nil -> register_user(%{email: @demo_email})
      user -> {:ok, user}
    end
  end
end
