defmodule ReadoutWeb.SourcesLiveTest do
  use ReadoutWeb.ConnCase, async: true
  use Oban.Testing, repo: Readout.Repo

  import Phoenix.LiveViewTest
  import Readout.CurationFixtures

  alias Readout.Ingestion.UserSource
  alias Readout.Repo
  alias Readout.Workers.SourceFetchWorker

  test "redirects anonymous users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/sources")
  end

  describe "authenticated user" do
    setup :register_and_log_in_user

    test "shows the signed-in shell and first-source form when there are no Sources", %{
      conn: conn
    } do
      {:ok, view, html} = live(conn, ~p"/sources")

      assert html =~ "Add your first source"

      assert has_element?(
               view,
               ~s(nav[aria-label="Product"] a[href="/sources"][aria-current="page"]),
               "Sources"
             )

      assert has_element?(view, "#source-form")
      assert has_element?(view, ~s(label[for="source_url"]), "RSS or Atom URL")

      assert has_element?(
               view,
               ~s(input[name="source[url]"][placeholder="https://example.com/feed.xml"])
             )

      assert has_element?(view, ~s(button[type="submit"]), "Add source")
    end

    test "adds a valid RSS Source and stays on Sources", %{conn: conn} do
      stub_valid_feed()
      {:ok, view, _html} = live(conn, ~p"/sources")

      html =
        view
        |> form("#source-form", source: %{url: "HTTPS://Example.COM/feed.xml#latest"})
        |> render_submit()

      assert html =~ "Source added. Fetching articles now."
      assert has_element?(view, "#source-list", "example.com")
      assert has_element?(view, "#source-list", "https://example.com/feed.xml")
      assert_enqueued(worker: SourceFetchWorker)
    end

    test "shows an actionable error for an invalid URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/sources")

      html =
        view
        |> form("#source-form", source: %{url: "not a url"})
        |> render_submit()

      assert html =~ "Enter a valid RSS or Atom URL"
      assert has_element?(view, "#source-form-error")
    end

    test "shows an actionable error for an unreachable feed", %{conn: conn} do
      Req.Test.stub(Readout.HTTP, fn conn ->
        Plug.Conn.send_resp(conn, 404, "not found")
      end)

      {:ok, view, _html} = live(conn, ~p"/sources")

      html =
        view
        |> form("#source-form", source: %{url: "https://example.com/missing.xml"})
        |> render_submit()

      assert html =~ "Readout could not reach that feed (HTTP 404)."
      assert has_element?(view, "#source-form-error")
    end

    test "shows an actionable error for a URL that is not RSS or Atom", %{conn: conn} do
      Req.Test.stub(Readout.HTTP, fn conn ->
        Plug.Conn.send_resp(conn, 200, "<html><body>Not a feed</body></html>")
      end)

      {:ok, view, _html} = live(conn, ~p"/sources")

      html =
        view
        |> form("#source-form", source: %{url: "https://example.com/page"})
        |> render_submit()

      assert html =~ "That URL did not return a valid RSS or Atom feed."
      assert has_element?(view, "#source-form-error")
    end

    test "only lists Sources subscribed by the current User", %{conn: conn} do
      foreign_source = source_fixture(name: "Other user's source")
      other = Readout.AccountsFixtures.user_fixture()

      Repo.insert!(%UserSource{user_id: other.id, source_id: foreign_source.id})

      {:ok, view, _html} = live(conn, ~p"/sources")

      refute has_element?(view, "#source-list", "Other user's source")
    end
  end

  defp stub_valid_feed do
    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, "<rss><channel></channel></rss>")
    end)
  end
end
