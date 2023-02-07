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
      ] ++ servers(env: Mix.env()) ++ [ShortenerWeb.Endpoint]

    opts = [strategy: :one_for_one, name: Shortener.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ShortenerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp servers(env: :test), do: []
  defp servers(env: _), do: [Shortener.ShortenedURLs.StatsServer]
end
