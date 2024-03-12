defmodule Elixchat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixchatWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:elixchat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Elixchat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Elixchat.Finch},
      {ConfigCat, [sdk_key: "gnLbCJ_nhUCGHl1SZNyC5Q/V794nqFnpkWY_7TuhXTaOw"]},
      # Start a worker by calling: Elixchat.Worker.start_link(arg)
      # {Elixchat.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixchatWeb.Endpoint,

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elixchat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixchatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
