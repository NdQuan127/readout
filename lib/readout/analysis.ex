defmodule Readout.Analysis do
  require Logger

  alias Readout.Analysis.{ArticleSummary, GeminiClient}
  alias Readout.Ingestion
  alias Readout.Repo

  @max_content_length 15_000
  @max_tags 3

  def summarize_article(article_id) do
    case Ingestion.get_article_for_processing(article_id) do
      nil ->
        {:cancel, "Article not found"}

      article ->
        if is_nil(article.content) do
          {:cancel, "Content not found"}
        else
          summarize_content(article)
        end
    end
  end

  defp summarize_content(article) do
    article.content.text
    |> String.slice(0, @max_content_length)
    |> GeminiClient.generate_summary()
    |> case do
      {:ok, attrs} ->
        summary = upsert_summary(article, attrs)
        log_usage(attrs[:usage])
        broadcast_summarized(article)
        {:ok, summary}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp upsert_summary(article, attrs) do
    attrs = %{
      article_id: article.id,
      summary_text: attrs.summary_text,
      tags: normalize_tags(attrs.tags)
    }

    %ArticleSummary{}
    |> ArticleSummary.changeset(attrs)
    |> Repo.insert!(
      on_conflict: [set: [summary_text: attrs.summary_text, tags: attrs.tags, updated_at: now()]],
      conflict_target: :article_id,
      returning: true
    )
  end

  defp normalize_tags(tags) when is_list(tags) do
    allowed_tags =
      :readout
      |> Application.fetch_env!(__MODULE__)
      |> Keyword.fetch!(:tags)
      |> Map.new(fn tag -> {normalize_tag(tag), tag} end)

    tags
    |> Enum.map(&Map.get(allowed_tags, normalize_tag(&1)))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.take(@max_tags)
  end

  defp normalize_tags(_tags), do: []

  defp normalize_tag(tag) when is_binary(tag), do: tag |> String.trim() |> String.downcase()
  defp normalize_tag(_tag), do: ""

  defp log_usage(nil), do: :ok

  defp log_usage(usage) do
    Logger.debug("Gemini usage: #{inspect(usage)}")
  end

  defp broadcast_summarized(article) do
    Phoenix.PubSub.broadcast(
      Readout.PubSub,
      "source:#{article.source_id}:summarized",
      {:article_summarized, article.id}
    )
  end

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)
end
