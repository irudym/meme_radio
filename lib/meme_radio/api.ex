defmodule MemeRadio.Api do

  require Logger

  def post_request(url, key, request) do
    Req.post(url,
      json: request,
      auth: {:bearer, key}
    )
  end

  def fetch_async_data(url, key, request) do
    result = fetch_data(url, key, request)
      |> Task.await(:infinity)
    {:ok, result}
  end

  def fetch_data(url, key, request) do
    Task.async(fn ->
      post_request(url, key, request)
    end)
  end

  defp parse_delay(delay) when is_integer(delay), do: delay
  defp parse_delay(delay) when is_binary(delay), do: String.to_integer(delay)
end
