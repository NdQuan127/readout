defmodule ReadoutWeb.MarkdownHelpersTest do
  use ExUnit.Case, async: true

  alias ReadoutWeb.MarkdownHelpers

  describe "render_markdown/1" do
    test "renders Markdown formatting to safe HTML" do
      markdown = """
      # Headline

      A **bold** takeaway with [a link](https://example.com).

      - First
      - Second
      """

      assert {:safe, html} = MarkdownHelpers.render_markdown(markdown)

      assert html =~ "<h1>Headline</h1>"
      assert html =~ "<strong>bold</strong>"
      assert html =~ ~s(<a href="https://example.com")
      assert html =~ ">a link</a>"
      refute html =~ "target="
      assert html =~ "<ul>"
      assert html =~ "<li>First</li>"
      assert html =~ "<li>Second</li>"
    end

    test "sanitizes raw HTML and dangerous attributes" do
      markdown =
        ~s|<script>alert("xss")</script><a href="https://example.com" onclick="steal()">safe link</a>|

      assert {:safe, html} = MarkdownHelpers.render_markdown(markdown)

      refute html =~ "<script"
      refute html =~ "alert("
      refute html =~ "onclick"
      refute html =~ "steal()"
      assert html =~ ~s(<a href="https://example.com")
      assert html =~ ">safe link</a>"
      refute html =~ "target="
    end
  end
end
