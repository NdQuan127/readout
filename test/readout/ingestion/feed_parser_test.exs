defmodule Readout.Ingestion.FeedParserTest do
  use ExUnit.Case, async: true

  alias Readout.Ingestion.FeedParser

  test "parses articles from an RSS document" do
    document = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <item>
          <title>Elixir 1.20 Released</title>
          <link>https://example.com/elixir-1-20</link>
          <pubDate>Tue, 09 Jun 2026 08:30:00 GMT</pubDate>
        </item>
      </channel>
    </rss>
    """

    assert {:ok,
            [
              %{
                title: "Elixir 1.20 Released",
                url: "https://example.com/elixir-1-20",
                published_at: ~U[2026-06-09 08:30:00Z]
              }
            ]} = FeedParser.parse(document)
  end

  test "parses articles from an Atom document" do
    document = """
    <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
        <title>OTP Patterns</title>
        <link href="https://example.com/otp-patterns" />
        <updated>2026-06-09T08:30:00Z</updated>
      </entry>
    </feed>
    """

    assert {:ok,
            [
              %{
                title: "OTP Patterns",
                url: "https://example.com/otp-patterns",
                published_at: ~U[2026-06-09 08:30:00Z]
              }
            ]} = FeedParser.parse(document)
  end

  test "unwraps CDATA in RSS article titles" do
    document = """
    <rss version="2.0">
      <channel>
        <item>
          <title><![CDATA[Am I Meant To Be Impressed?]]></title>
          <link>https://example.com/impressed</link>
        </item>
      </channel>
    </rss>
    """

    assert {:ok, [%{title: "Am I Meant To Be Impressed?"}]} = FeedParser.parse(document)
  end
end
