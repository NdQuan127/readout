# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Readout.Repo.insert!(%Readout.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias Readout.Accounts
alias Readout.Accounts.User
alias Readout.Repo

operator_email = "operator@readout.local"

Repo.delete_all(from(user in User, where: user.email == "demo@readout.local"))

case Accounts.get_user_by_email(operator_email) do
  nil ->
    {:ok, user} = Accounts.register_user(%{email: operator_email})
    user |> User.confirm_changeset() |> Repo.update!()

  %User{confirmed_at: nil} = user ->
    user |> User.confirm_changeset() |> Repo.update!()

  _user ->
    :ok
end
