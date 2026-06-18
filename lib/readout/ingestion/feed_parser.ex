defmodule Readout.Ingestion.FeedParser do
  def parse(document) when is_binary(document) do
    case Floki.parse_document(document) do
      {:ok, tree} ->
        entries = Floki.find(tree, "item") ++ Floki.find(tree, "entry")

        if feed_document?(tree) do
          {:ok, Enum.map(entries, &parse_entry/1)}
        else
          {:error, :invalid_rss_format}
        end

      {:error, _reason} ->
        {:error, :invalid_rss_format}
    end
  end

  defp feed_document?(tree) do
    Floki.find(tree, "rss, feed") != []
  end

  defp parse_entry(entry) do
    %{
      title: text(entry, "title"),
      url: entry_url(entry),
      published_at:
        entry
        |> published_at_text()
        |> parse_published_at()
    }
  end

  defp published_at_text(entry) do
    text(entry, "pubdate") || text(entry, "published") || text(entry, "updated")
  end

  defp parse_published_at(nil), do: nil

  defp parse_published_at(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} ->
        datetime

      {:error, _reason} ->
        parse_request_date(value)
    end
  end

  defp parse_request_date(value) do
    case :httpd_util.convert_request_date(String.to_charlist(value)) do
      {{year, month, day}, {hour, minute, second}} ->
        DateTime.new!(Date.new!(year, month, day), Time.new!(hour, minute, second), "Etc/UTC")

      :bad_date ->
        nil
    end
  end

  defp entry_url(entry) do
    text(entry, "link") ||
      case Floki.find(entry, "link") do
        [link | _] -> link |> Floki.attribute("href") |> List.first()
        [] -> nil
      end
  end

  defp text(entry, selector) do
    case Floki.find(entry, selector) do
      [] ->
        nil

      nodes ->
        case nodes |> Floki.text() |> String.trim() |> unwrap_cdata() do
          "" -> nil
          value -> value
        end
    end
  end

  defp unwrap_cdata("<![CDATA[" <> value) do
    String.replace_suffix(value, "]]>", "")
  end

  defp unwrap_cdata(value), do: value
end
