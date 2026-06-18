defmodule Readout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReadoutWeb.Telemetry,
      Readout.Repo,
      {Oban, Application.fetch_env!(:readout, Oban)},
      {DNSCluster, query: Application.get_env(:readout, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Readout.PubSub},
      # Start a worker by calling: Readout.Worker.start_link(arg)
      # {Readout.Worker, arg},
      # Start to serve requests, typically the last entry
      ReadoutWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Readout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReadoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
