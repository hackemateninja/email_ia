defmodule EmailIa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    credentials = %{
      "refresh_token" => "your_refresh_token_string",
      "client_id" => "550896010777-…",
      "client_secret" => "GOCSPX‑M_LUOinsR…"
    }

    children = [
      EmailIaWeb.Telemetry,
      EmailIa.Repo,
      {DNSCluster, query: Application.get_env(:email_ia, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EmailIa.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: EmailIa.Finch},
      {Goth, name: GmailGoth, source: {:refresh_token, credentials, []}},
      # Start a worker by calling: EmailIa.Worker.start_link(arg)
      # {EmailIa.Worker, arg},
      # Start to serve requests, typically the last entry
      EmailIaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmailIa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmailIaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
