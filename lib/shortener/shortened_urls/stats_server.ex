defmodule Shortener.ShortenedURLs.StatsServer do
  use GenServer
  alias Shortener.ShortenedURLs

  @moduledoc """
  StatsServer keeps track of Shortened URL page views. Everytime a Shortened URL
  is requested, we increment the page views counter in the StatsServer state. Page
  views are then persisted in the database every configured interval (`:stats_server_persist_interval`).

  We trap exits to make sure page views are persisted in the event StatsServer goes
  down or the application is shutting down.
  """

  @name __MODULE__
  @initial_value 1

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)
    schedule_work()
    {:ok, state}
  end

  def track_page_view(slug) do
    GenServer.cast(@name, {:track_page_view, slug})
  end

  @impl true
  def handle_cast({:track_page_view, slug}, state) do
    new_state = Map.update(state, slug, @initial_value, &(&1 + 1))
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:persist_page_views, state) do
    Task.Supervisor.async_nolink(Shortener.TaskSupervisor, fn ->
      ShortenedURLs.persist_page_views(state)
      :persisted
    end)

    new_state = %{}
    {:noreply, new_state}
  end

  @impl true
  def handle_info({_ref, :persisted}, state) do
    schedule_work()
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, _, _, :normal}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, _, _, _error}, state) do
    schedule_work()
    {:noreply, state}
  end

  @impl true
  def terminate(_, state) do
    ShortenedURLs.persist_page_views(state)
  end

  defp schedule_work do
    update_interval = Application.get_env(:shortener, :stats_server_persist_interval)
    Process.send_after(self(), :persist_page_views, update_interval)
  end
end
