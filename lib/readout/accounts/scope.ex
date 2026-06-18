defmodule Readout.Accounts.Scope do
  alias Readout.Accounts.User

  defstruct [:user]

  def for_user(%User{} = user), do: %__MODULE__{user: user}
end
