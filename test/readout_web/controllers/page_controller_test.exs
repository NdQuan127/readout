defmodule ReadoutWeb.PageControllerTest do
  use ReadoutWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Readout"
  end

  @tag :authenticated
  test "GET / redirects logged-in users to demo", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})

    conn = get(conn, ~p"/")

    assert redirected_to(conn) == ~p"/demo"
  end
end
