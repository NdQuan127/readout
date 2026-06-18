defmodule ReadoutWeb.PageController do
  use ReadoutWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
