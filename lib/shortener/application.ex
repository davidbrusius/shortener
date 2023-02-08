defmodule Shortener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        Shortener.Repo,
        ShortenerWeb.Telemetry,
        {Phoenix.PubSub, name: Shortener.PubSub},
        {Task.Supervisor, name: Shortener.TaskSupervisor}
      ] ++ servers() ++ [ShortenerWeb.Endpoint]

    opts = [strategy: :one_for_one, name: Shortener.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ShortenerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp servers do
    if Application.fetch_env!(:shortener, :stats_server_enabled) do
      [Shortener.ShortenedURLs.StatsServer]
    else
      []
    end
  end
end
