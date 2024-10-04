defmodule MemeRadio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MemeRadioWeb.Telemetry,
      MemeRadio.Repo,
      {DNSCluster, query: Application.get_env(:meme_radio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MemeRadio.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MemeRadio.Finch},
      # Start a worker by calling: MemeRadio.Worker.start_link(arg)
      # {MemeRadio.Worker, arg},
      # Start to serve requests, typically the last entry
      MemeRadioWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MemeRadio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MemeRadioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
