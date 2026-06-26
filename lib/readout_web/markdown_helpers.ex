defmodule ReadoutWeb.MarkdownHelpers do
  @moduledoc """
  Shared helpers for rendering user-visible Markdown as safe HTML.
  """

  @doc """
  Renders Markdown to sanitized HTML suitable for HEEx templates.

  Markdown is rendered at display time so persisted Summary content remains the
  source-of-truth Markdown. Raw HTML is allowed during Markdown rendering only so
  MDEx's sanitizer can strip unsafe tags and attributes before the result is
  marked safe for Phoenix.
  """
  def render_markdown(markdown) when is_binary(markdown) do
    html =
      MDEx.to_html!(markdown,
        render: [unsafe: true],
        sanitize: MDEx.Document.default_sanitize_options()
      )

    {:safe, html}
  end
end
