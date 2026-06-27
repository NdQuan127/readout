defmodule ReadoutWeb.PageController do
  use ReadoutWeb, :controller

  alias Readout.Accounts.Scope

  def home(%{assigns: %{current_scope: %Scope{user: user}}} = conn, _params)
      when not is_nil(user) do
    redirect(conn, to: ~p"/digest")
  end

  def home(conn, _params) do
    render(conn, :home)
  end
end
