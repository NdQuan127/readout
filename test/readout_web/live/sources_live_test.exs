defmodule ReadoutWeb.SourcesLiveTest do
  use ReadoutWeb.ConnCase, async: true
  use Oban.Testing, repo: Readout.Repo

  import Phoenix.LiveViewTest
  import Readout.CurationFixtures

  alias Readout.Ingestion.{Article, UserSource}
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
      assert has_element?(view, "#source-list", "Fetching articles")
      assert_enqueued(worker: SourceFetchWorker)
    end

    test "lists existing Sources with status and counts", %{conn: conn, scope: scope, user: user} do
      summarized_source =
        source_fixture(
          name: "Industry News",
          canonical_url: "https://industry.example/feed.xml"
        )

      article_source =
        source_fixture(
          name: "Fresh Wire",
          canonical_url: "https://fresh.example/feed.xml"
        )

      summary_fixture(scope, source: summarized_source)
      Repo.insert!(%UserSource{user_id: user.id, source_id: article_source.id})
      insert_article(article_source, title: "Fresh Article")

      {:ok, view, _html} = live(conn, ~p"/sources")

      assert has_element?(view, "#source-list", "Industry News")
      assert has_element?(view, "#source-list", "https://industry.example/feed.xml")
      assert has_element?(view, "#source-list", "Summaries ready")
      assert has_element?(view, "#source-list", "1 Article")
      assert has_element?(view, "#source-list", "1 Summary")

      assert has_element?(view, "#source-list", "Fresh Wire")
      assert has_element?(view, "#source-list", "https://fresh.example/feed.xml")
      assert has_element?(view, "#source-list", "Articles found")
      assert has_element?(view, "#source-list", "0 Summaries")

      refute has_element?(view, "#source-list", "Recent Articles")
    end

    test "existing Sources show a toolbar Add source action that opens an inline panel", %{
      conn: conn,
      user: user
    } do
      source = source_fixture(name: "Existing Source")
      Repo.insert!(%UserSource{user_id: user.id, source_id: source.id})

      {:ok, view, _html} = live(conn, ~p"/sources")

      assert has_element?(view, "#show-add-source", "Add source")
      refute has_element?(view, "#add-source-panel")
      refute has_element?(view, ~s([role="dialog"]))

      render_click(element(view, "#show-add-source"))

      assert has_element?(view, "#add-source-panel")
      assert has_element?(view, "#source-form")
      refute has_element?(view, ~s([role="dialog"]))
    end

    test "adds another valid Source from the inline panel and updates the list", %{
      conn: conn,
      user: user
    } do
      existing_source = source_fixture(name: "Existing Source")
      Repo.insert!(%UserSource{user_id: user.id, source_id: existing_source.id})
      stub_valid_feed()
      {:ok, view, _html} = live(conn, ~p"/sources")

      render_click(element(view, "#show-add-source"))

      html =
        view
        |> form("#source-form", source: %{url: "https://example.com/new-feed.xml"})
        |> render_submit()

      assert html =~ "Source added. Fetching articles now."
      assert has_element?(view, "#source-list", "Existing Source")
      assert has_element?(view, "#source-list", "example.com")
      assert has_element?(view, "#source-list", "https://example.com/new-feed.xml")
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

    test "only lists Sources and counts subscribed by the current User", %{
      conn: conn,
      user: user
    } do
      own_source = source_fixture(name: "My source")
      foreign_source = source_fixture(name: "Other user's source")
      other = Readout.AccountsFixtures.user_fixture()

      Repo.insert!(%UserSource{user_id: user.id, source_id: own_source.id})
      Repo.insert!(%UserSource{user_id: other.id, source_id: foreign_source.id})
      insert_article(foreign_source, title: "Foreign article")

      {:ok, view, _html} = live(conn, ~p"/sources")

      assert has_element?(view, "#source-list", "My source")
      assert has_element?(view, "#source-list", "0 Articles")
      refute has_element?(view, "#source-list", "Other user's source")
      refute has_element?(view, "#source-list", "Foreign article")
      refute has_element?(view, "#source-list", "1 Article")
    end
  end

  defp stub_valid_feed do
    Req.Test.stub(Readout.HTTP, fn conn ->
      Plug.Conn.send_resp(conn, 200, "<rss><channel></channel></rss>")
    end)
  end

  defp insert_article(source, attrs) do
    Repo.insert!(%Article{
      source_id: source.id,
      canonical_url:
        attrs[:canonical_url] ||
          "https://example#{System.unique_integer([:positive])}.com/article",
      title: attrs[:title] || "Article #{System.unique_integer([:positive])}",
      published_at: attrs[:published_at] || DateTime.utc_now(:second)
    })
  end
end
