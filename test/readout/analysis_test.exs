defmodule Readout.AnalysisTest do
  use Readout.DataCase, async: true
  use Oban.Testing, repo: Readout.Repo

  alias Readout.Analysis.ArticleSummary
  alias Readout.Ingestion.{Article, ArticleContent, Source}
  alias Readout.Workers.ArticleSummarizeWorker

  test "summarize worker stores Summary, drops unknown tags, and sends truncated Content" do
    source =
      Repo.insert!(%Source{
        canonical_url: "https://example.com/feed.xml",
        name: "Example"
      })

    article =
      Repo.insert!(%Article{
        source_id: source.id,
        canonical_url: "https://example.com/article",
        title: "Article"
      })

    Repo.insert!(%ArticleContent{
      article_id: article.id,
      text: String.duplicate("a", 15_010)
    })

    Req.Test.stub(Readout.Analysis.GeminiClient, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      request = Jason.decode!(body)
      prompt = get_in(request, ["contents", Access.at(0), "parts", Access.at(0), "text"])

      assert get_in(request, ["generationConfig", "responseMimeType"]) == "application/json"

      assert get_in(request, ["generationConfig", "responseSchema", "required"]) == [
               "summary_text",
               "tags"
             ]

      assert String.contains?(prompt, String.duplicate("a", 15_000))
      refute String.contains?(prompt, String.duplicate("a", 15_001))

      Req.Test.json(conn, %{
        "candidates" => [
          %{
            "content" => %{
              "parts" => [
                %{
                  "text" =>
                    Jason.encode!(%{
                      "summary_text" => "Bản tóm tắt ngắn.",
                      "tags" => ["AI", "unknown", "technology", "world"]
                    })
                }
              ]
            }
          }
        ],
        "usageMetadata" => %{"totalTokenCount" => 42}
      })
    end)

    assert :ok = perform_job(ArticleSummarizeWorker, %{article_id: article.id})

    assert %ArticleSummary{
             summary_text: "Bản tóm tắt ngắn.",
             tags: ["ai", "technology", "world"]
           } = Repo.get_by(ArticleSummary, article_id: article.id)
  end
end
