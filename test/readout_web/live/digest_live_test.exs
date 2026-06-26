defmodule ReadoutWeb.DigestLiveTest do
  use ReadoutWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Readout.Analysis.ArticleSummary
  alias Readout.Ingestion.{Article, Source, UserSource}
  alias Readout.Repo

  test "redirects anonymous users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/digest")
  end

  describe "authenticated operator" do
    setup :register_and_log_in_user

    test "shows an empty state before a digest is generated", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/digest")

      assert html =~ "Chưa có digest hôm nay"
    end

    test "generates today's digest for subscribed Sources without duplicates", %{
      conn: conn,
      scope: scope
    } do
      subscribed =
        summary_fixture(scope,
          title: "Subscribed article",
          summary_text: "Tin thuộc nguồn đã subscribe.",
          tags: ["technology"]
        )

      unsubscribed =
        summary_fixture(
          title: "Unsubscribed article",
          summary_text: "Tin không nên xuất hiện.",
          tags: ["business"]
        )

      {:ok, view, _html} = live(conn, ~p"/digest")

      view
      |> element("button", "Tạo digest hôm nay")
      |> render_click()

      html = render(view)
      assert html =~ subscribed.article.title
      assert html =~ subscribed.summary_text
      assert html =~ "technology"
      refute html =~ unsubscribed.article.title
      refute html =~ unsubscribed.summary_text

      view
      |> element("button", "Tạo digest hôm nay")
      |> render_click()

      html = render(view)
      assert html =~ subscribed.summary_text

      assert html |> Floki.parse_document!() |> Floki.find("#digest-items article") |> length() ==
               1
    end

    test "renders Markdown summary content as sanitized HTML", %{conn: conn, scope: scope} do
      summary_fixture(scope,
        title: "Markdown article",
        summary_text: """
        ## Why it matters

        This is **important**.

        - One
        - Two

        [Read more](https://example.com/article)

        <script>alert("xss")</script><a href="https://example.com" onclick="steal()">safe link</a>
        """
      )

      {:ok, view, _html} = live(conn, ~p"/digest")

      view
      |> element("button", "Tạo digest hôm nay")
      |> render_click()

      html = render(view)

      assert html =~ "<h2>Why it matters</h2>"
      assert html =~ "<strong>important</strong>"
      assert html =~ "<li>One</li>"
      assert html =~ ~s(href="https://example.com/article")
      assert html =~ ">Read more</a>"
      assert html =~ ">safe link</a>"
      refute html =~ "**important**"
      refute html =~ "<script"
      refute html =~ "onclick"
      refute html =~ "target="
    end

    test "orders digest items by Article published time descending", %{conn: conn, scope: scope} do
      today = Date.utc_today()

      older =
        summary_fixture(scope,
          title: "Older article",
          summary_text: "Older summary",
          published_at: at_hour(today, 8)
        )

      newer =
        summary_fixture(scope,
          title: "Newer article",
          summary_text: "Newer summary",
          published_at: at_hour(today, 16)
        )

      {:ok, view, _html} = live(conn, ~p"/digest")

      view
      |> element("button", "Tạo digest hôm nay")
      |> render_click()

      titles =
        view
        |> render()
        |> Floki.parse_document!()
        |> Floki.find("#digest-items article a")
        |> Enum.map(&(Floki.text(&1) |> String.trim()))

      assert titles == [newer.article.title, older.article.title]
    end
  end

  defp summary_fixture(attrs) do
    summary_fixture(nil, attrs)
  end

  defp summary_fixture(scope, attrs) do
    source = source_fixture()

    if scope do
      Repo.insert!(%UserSource{user_id: scope.user.id, source_id: source.id})
    end

    article =
      Repo.insert!(%Article{
        source_id: source.id,
        canonical_url: unique_url(),
        title: attrs[:title] || "Article #{System.unique_integer([:positive])}",
        published_at: attrs[:published_at] || DateTime.utc_now(:second)
      })

    Repo.insert!(%ArticleSummary{
      article_id: article.id,
      summary_text: attrs[:summary_text] || "Summary #{System.unique_integer([:positive])}",
      tags: attrs[:tags] || ["technology"],
      inserted_at: attrs[:inserted_at] || DateTime.utc_now(:second),
      updated_at: attrs[:inserted_at] || DateTime.utc_now(:second)
    })
    |> Repo.preload(:article)
  end

  defp source_fixture do
    Repo.insert!(%Source{
      canonical_url: unique_url(),
      name: "Source #{System.unique_integer([:positive])}"
    })
  end

  defp at_hour(date, hour) do
    DateTime.new!(date, Time.new!(hour, 0, 0), "Etc/UTC") |> DateTime.truncate(:second)
  end

  defp unique_url do
    "https://example#{System.unique_integer([:positive])}.com/feed.xml"
  end
end
