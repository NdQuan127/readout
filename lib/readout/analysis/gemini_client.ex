defmodule Readout.Analysis.GeminiClient do
  @schema %{
    type: "object",
    properties: %{
      summary_text: %{type: "string"},
      tags: %{type: "array", items: %{type: "string"}}
    },
    required: ["summary_text", "tags"]
  }

  def generate_summary(content) when is_binary(content) do
    config = Application.fetch_env!(:readout, __MODULE__)

    with {:ok, api_key} <- api_key(config),
         {:ok, response} <- request(config, api_key, content),
         {:ok, attrs} <- decode_response(response) do
      {:ok, attrs}
    end
  end

  defp api_key(config) do
    case Keyword.get(config, :api_key) || System.get_env("GEMINI_API_KEY") do
      nil -> {:error, :missing_gemini_api_key}
      "" -> {:error, :missing_gemini_api_key}
      api_key -> {:ok, api_key}
    end
  end

  defp request(config, api_key, content) do
    endpoint = Keyword.fetch!(config, :endpoint)
    model = Keyword.fetch!(config, :model)

    options =
      [
        url: "#{endpoint}/models/#{model}:generateContent",
        headers: [{"x-goog-api-key", api_key}],
        json: request_body(content)
      ] ++ Keyword.get(config, :req_options, [])

    case Req.post(options) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_status, status}}

      {:error, exception} ->
        {:error, exception}
    end
  end

  defp request_body(content) do
    %{
      contents: [
        %{
          role: "user",
          parts: [%{text: prompt(content)}]
        }
      ],
      generationConfig: %{
        responseMimeType: "application/json",
        responseSchema: @schema
      }
    }
  end

  defp prompt(content) do
    """
    Summarize this article in Vietnamese.

    Return only the JSON object matching the provided schema.
    Use at most three tags from the configured closed vocabulary.

    Article:
    #{content}
    """
  end

  defp decode_response(
         %{"candidates" => [%{"content" => %{"parts" => [%{"text" => text} | _]}} | _]} = body
       ) do
    with {:ok, %{"summary_text" => summary_text, "tags" => tags}} <- Jason.decode(text) do
      {:ok,
       %{
         summary_text: summary_text,
         tags: tags,
         usage: Map.get(body, "usageMetadata")
       }}
    end
  end

  defp decode_response(_body), do: {:error, :invalid_gemini_response}
end
