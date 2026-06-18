defmodule Readout.HTTP do
  def get(url) do
    options = [url: url] ++ Application.get_env(:readout, __MODULE__, [])

    case Req.get(options) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_status, status}}

      {:error, exception} ->
        {:error, exception}
    end
  end
end
