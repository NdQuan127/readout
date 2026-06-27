defmodule ReadoutWeb.DigestLiveTest do
  use ReadoutWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Readout.CurationFixtures

  alias Readout.Curation
  alias Readout.Ingestion.UserSource
  alias Readout.Repo

  test "redirects anonymous users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/digest")
  end

  describe "authenticated operator" do
    setup :register_and_log_in_user

    test "shows the no-Sources empty state with a CTA to Sources", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/digest")

      assert has_element?(view, "#digest-empty", "No sources yet")
      assert has_element?(view, "#digest-empty", "RSS or Atom source")
      assert has_element?(view, "#digest-empty", "build your daily digest")
      assert has_element?(view, ~s(#digest-empty a[href="/sources"]), "Add source")
      refute has_element?(view, "#digest-empty", "Generate digest")

      assert {:error, {:live_redirect, %{to: "/sources"}}} =
               view |> element("#digest-empty a", "Add source") |> render_click()
    end

    test "shows the Sources-but-no-Summary empty state with a CTA to Sources", %{
      conn: conn,
      user: user
    } do
      source = source_fixture(name: "Waiting Source")
      Repo.insert!(%UserSource{user_id: user.id, source_id: source.id})

      {:ok, view, _html} = live(conn, ~p"/digest")

      assert has_element?(view, "#digest-empty", "No summaries ready yet")
      assert has_element?(view, "#digest-empty", "fetching and summarizing articles")
      assert has_element?(view, ~s(#digest-empty a[href="/sources"]), "View sources")
      refute has_element?(view, "#digest-empty", "Generate digest")

      assert {:error, {:live_redirect, %{to: "/sources"}}} =
               view |> element("#digest-empty a", "View sources") |> render_click()
    end

    test "regenerates today's digest for subscribed Sources without duplicates", %{
      conn: conn,
      scope: scope
    } do
      subscribed =
        summary_fixture(scope,
          title: "Subscribed article",
          summary_text: "News from a subscribed source.",
          tags: ["technology"]
        )

      unsubscribed =
        summary_fixture(
          title: "Unsubscribed article",
          summary_text: "News that should not appear."
        )

      {:ok, _digest} = Curation.generate_digest(scope, Date.utc_today())
      {:ok, view, _html} = live(conn, ~p"/digest")

      html = render(view)
      assert html =~ subscribed.article.title
      assert html =~ subscribed.article.source.name
      assert html =~ "technology"
      refute html =~ unsubscribed.article.title

      view |> element("#generate-digest") |> render_click()

      assert view
             |> render()
             |> Floki.parse_document!()
             |> Floki.find("#digest-items [id^=\"digest-item-\"]")
             |> length() == 1
    end

    test "selecting an item patches to /digest/:id and shows its summary in the detail pane",
         %{conn: conn, scope: scope} do
      summary =
        generate_with(scope, [
          [title: "Selected article", summary_text: "## Deep dive\n\nThe **body** text."]
        ])
        |> hd()

      {:ok, view, _html} = live(conn, ~p"/digest")

      refute has_element?(view, "#detail-pane h1", "Selected article")
      assert has_element?(view, "#detail-empty")

      view |> element("#digest-item-#{summary.id} a") |> render_click()

      assert_patch(view, ~p"/digest/#{summary.id}")
      assert has_element?(view, "#detail-pane", "Selected article")
      assert has_element?(view, "#detail-pane strong", "body")
      assert has_element?(view, ~s(#detail-pane a[href="#{summary.article.canonical_url}"]))
      refute has_element?(view, "#detail-empty")
    end

    test "marks the selected item active in the list", %{conn: conn, scope: scope} do
      summary = generate_with(scope, [[title: "Active article"]]) |> hd()

      {:ok, view, _html} = live(conn, ~p"/digest/#{summary.id}")

      assert has_element?(view, ~s(#digest-item-#{summary.id}[aria-current="true"]))
    end

    test "deep-linking to /digest/:id keeps that article selected on load", %{
      conn: conn,
      scope: scope
    } do
      [first, second] =
        generate_with(scope, [
          [title: "First article", summary_text: "First body"],
          [title: "Second article", summary_text: "Second body"]
        ])

      {:ok, view, _html} = live(conn, ~p"/digest/#{second.id}")

      assert has_element?(view, "#detail-pane", "Second article")
      refute has_element?(view, "#detail-pane", first.article.title)
    end

    test "bare /digest shows the empty detail pane without auto-selecting", %{
      conn: conn,
      scope: scope
    } do
      generate_with(scope, [[title: "Only article"]])

      {:ok, view, _html} = live(conn, ~p"/digest")

      assert has_element?(view, "#detail-empty")
      refute has_element?(view, "#detail-pane h1")
    end

    test "an id outside today's digest patches back to /digest", %{conn: conn, scope: scope} do
      generate_with(scope, [[title: "Mine"]])

      bogus = Ecto.UUID.generate()

      {:ok, view, _html} = live(conn, ~p"/digest")
      render_patch(view, ~p"/digest/#{bogus}")

      assert_patch(view, ~p"/digest")
      assert has_element?(view, "#detail-empty")
    end

    test "another user's summary id patches back to /digest", %{conn: conn, scope: scope} do
      generate_with(scope, [[title: "Mine"]])

      other_scope = register_and_log_in_user(%{conn: build_conn()}).scope
      foreign = generate_with(other_scope, [[title: "Theirs"]]) |> hd()

      {:ok, view, _html} = live(conn, ~p"/digest")
      render_patch(view, ~p"/digest/#{foreign.id}")

      assert_patch(view, ~p"/digest")
    end

    test "filtering by Source narrows the list but keeps the open article in detail", %{
      conn: conn,
      scope: scope
    } do
      source_a = source_fixture(name: "Source A")
      source_b = source_fixture(name: "Source B")

      [from_a, from_b] =
        generate_with(scope, [
          [title: "Alpha story", source: source_a, summary_text: "Alpha body"],
          [title: "Beta story", source: source_b]
        ])

      {:ok, view, _html} = live(conn, ~p"/digest/#{from_a.id}")

      view
      |> element("#source-filter")
      |> render_change(%{"source" => from_b.article.source_id})

      refute has_element?(view, "#digest-item-#{from_a.id}")
      assert has_element?(view, "#digest-item-#{from_b.id}")
      # the open article stays in the detail pane even though it is filtered out
      assert has_element?(view, "#detail-pane", "Alpha story")

      view |> element("#source-filter") |> render_change(%{"source" => "all"})
      assert has_element?(view, "#digest-item-#{from_a.id}")
      assert has_element?(view, "#digest-item-#{from_b.id}")
    end

    test "regenerating resets the source filter so the list is not silently narrowed", %{
      conn: conn,
      scope: scope
    } do
      source_a = source_fixture(name: "Source A")
      source_b = source_fixture(name: "Source B")

      [from_a, from_b] =
        generate_with(scope, [
          [title: "Alpha story", source: source_a],
          [title: "Beta story", source: source_b]
        ])

      {:ok, view, _html} = live(conn, ~p"/digest")

      view |> element("#source-filter") |> render_change(%{"source" => from_a.article.source_id})
      refute has_element?(view, "#digest-item-#{from_b.id}")

      view |> element("#generate-digest") |> render_click()

      # the filter is back to "all": both items show again, and the dropdown reflects it
      assert has_element?(view, "#digest-item-#{from_a.id}")
      assert has_element?(view, "#digest-item-#{from_b.id}")
      assert has_element?(view, ~s(#source-filter option[value="all"][selected]))
    end

    test "orders digest items by Article published time descending", %{conn: conn, scope: scope} do
      today = Date.utc_today()

      [newer, older] =
        generate_with(scope, [
          [title: "Older article", published_at: at_hour(today, 8)],
          [title: "Newer article", published_at: at_hour(today, 16)]
        ])
        |> Enum.sort_by(& &1.article.published_at, {:desc, DateTime})

      {:ok, view, _html} = live(conn, ~p"/digest")

      titles =
        view
        |> render()
        |> Floki.parse_document!()
        |> Floki.find("#digest-items [id^=\"digest-item-\"]")
        |> Enum.map(
          &(Floki.find(&1, "[data-role=\"item-title\"]")
            |> Floki.text()
            |> String.trim())
        )

      assert titles == [newer.article.title, older.article.title]
    end

    test "renders Markdown summary content as sanitized HTML in the detail pane", %{
      conn: conn,
      scope: scope
    } do
      summary =
        generate_with(scope, [
          [
            title: "Markdown article",
            summary_text: """
            ## Why it matters

            This is **important**.

            <script>alert("xss")</script><a href="https://example.com" onclick="steal()">safe link</a>
            """
          ]
        ])
        |> hd()

      {:ok, view, _html} = live(conn, ~p"/digest/#{summary.id}")
      html = render(view)

      assert html =~ "<h2>Why it matters</h2>"
      assert html =~ "<strong>important</strong>"
      assert html =~ ">safe link</a>"
      refute html =~ "<script"
      refute html =~ "onclick"
    end
  end

  # Builds the listed Summaries then generates today's Digest, returning the
  # inserted Summaries (with article + source preloaded) in insertion order.
  defp generate_with(scope, summaries_attrs) do
    summaries = Enum.map(summaries_attrs, &summary_fixture(scope, &1))
    {:ok, _digest} = Curation.generate_digest(scope, Date.utc_today())
    summaries
  end

  defp at_hour(date, hour) do
    DateTime.new!(date, Time.new!(hour, 0, 0), "Etc/UTC") |> DateTime.truncate(:second)
  end
end
