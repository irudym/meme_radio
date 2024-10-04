defmodule MemeRadioWeb.MemeLive.Index do
  use MemeRadioWeb, :live_view
  alias MemeRadio.Openai
  require Logger



  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket
            |> assign(:changeset, %{})
            |> assign(:uploaded_files, [])
            |> assign(:result, nil)
            |> assign(:loading, false)
            |> allow_upload(:photo, accept: :any)
    }
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do

    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:meme_radio), "static", "uploads", Path.basename(path)])
        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    IO.inspect(uploaded_files)

    path = Path.join([:code.priv_dir(:meme_radio), "static", Enum.at(uploaded_files,0)])

    {:ok, content} = File.read(path)
    content_base64 = Base.encode64(content)


    fetch_data(%{model: "gpt-4o-mini", messages:
                [%{
                    role: "user",
                    content: [
                      %{
                        type: "text",
                        text: "Describe the photo in style of UK BBC 1940 radio, using some humour, remove mention of Internet, add words: 'peculiar, my goodness, well, ha-ha, jolly good'."
                      },
                      %{
                        type: "image_url",
                        image_url: %{
                          url: "data:image/jpeg;base64,#{content_base64}"
                        }
                      }
                    ]
                  }
                ], temperature: 0.7})
    # TODO: delete file

    {:noreply, socket
                  |> update(:uploaded_files, &(&1 ++ uploaded_files))
                  |> put_flash(:info, "File uploaded!")
                  |> assign(:loading, true)
                  |> assign(:result, nil)
    }
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"


  def fetch_data(request) do
    Task.async(fn ->
      Openai.openai_request(request)
    end)
  end

  @impl true
  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush])

    {:ok, {:ok, %{body: result}}} = result

    content = case result do
      %{"choices" => [%{"message" => %{"content" => content}}]} ->
        content
      _ ->
        nil
    end

    IO.inspect(content)


    socket =
      socket
      |> assign(:loading, false)
      |> assign(:result, content)

    {:noreply, socket}
  end

end
