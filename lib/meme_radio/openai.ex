defmodule MemeRadio.Openai do
  @chat_completions_url "https://api.openai.com/v1/chat/completions"
  import MemeRadio.Api

  def chat_completion(request) do
    Req.post(@chat_completions_url,
      json: request,
      auth: {:bearer, api_key()}
    )
  end

  def openai_request(request) do
    fetch_async_data(@chat_completions_url, api_key(), request)
  end


  defp api_key() do
    System.get_env("OPENAI_API_KEY")
  end

end
