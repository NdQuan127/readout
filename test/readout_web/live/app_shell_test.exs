defmodule ReadoutWeb.AppShellTest do
  use ReadoutWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "signed-in product shell" do
    setup :register_and_log_in_user

    test "shows product navigation, active Digest state, account actions, and theme controls", %{
      conn: conn,
      user: user
    } do
      {:ok, _view, html} = live(conn, ~p"/digest")
      document = Floki.parse_document!(html)

      assert document |> Floki.find(~s(nav[aria-label="Product"])) |> Floki.text() =~ "Digest"
      assert document |> Floki.find(~s(nav[aria-label="Product"])) |> Floki.text() =~ "Sources"

      assert document
             |> Floki.find(~s(nav[aria-label="Product"] a[href="/digest"][aria-current="page"]))
             |> Floki.text() =~ "Digest"

      assert document
             |> Floki.find(~s(nav[aria-label="Product"] a[href="/sources"]))
             |> Floki.text() =~ "Sources"

      assert Floki.find(
               document,
               ~s(nav[aria-label="Product"] a[href="/sources"][aria-current="page"])
             ) == []

      assert Floki.text(document) =~ user.email
      assert document |> Floki.find(~s(a[href="/users/settings"])) |> Floki.text() =~ "Settings"
      assert document |> Floki.find(~s(a[href="/users/log-out"])) |> Floki.text() =~ "Log out"

      assert Floki.find(
               document,
               ~s(button[aria-label="Use system theme"][data-phx-theme="system"])
             ) != []

      assert Floki.find(
               document,
               ~s(button[aria-label="Use light theme"][data-phx-theme="light"])
             ) != []

      assert Floki.find(document, ~s(button[aria-label="Use dark theme"][data-phx-theme="dark"])) !=
               []
    end
  end

  test "authentication pages keep the centered page layout instead of the product shell", %{
    conn: conn
  } do
    {:ok, _view, html} = live(conn, ~p"/users/log-in")
    document = Floki.parse_document!(html)

    assert Floki.find(document, ~s(#product-shell)) == []
    assert Floki.find(document, ~s(nav[aria-label="Product"])) == []
  end

  test "the public home page does not render the product shell", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)
    document = Floki.parse_document!(html)

    assert Floki.find(document, ~s(#product-shell)) == []
    assert Floki.find(document, ~s(nav[aria-label="Product"])) == []
  end
end
