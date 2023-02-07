defmodule Shortener.ShortenedURLs.StatsServerTest do
  use Shortener.DataCase
  alias Shortener.ShortenedURLs.{SlugGenerator, ShortenedURL, StatsServer}

  describe "init" do
    test "initializes the server state" do
      start_supervised!(StatsServer)
      assert %{} == :sys.get_state(StatsServer)
    end
  end

  describe "track_page_view/1" do
    test "tracks page view for a single slug" do
      start_supervised!(StatsServer)

      StatsServer.track_page_view("TESTSLUG")
      assert %{"TESTSLUG" => 1} == :sys.get_state(StatsServer)

      StatsServer.track_page_view("TESTSLUG")
      assert %{"TESTSLUG" => 2} == :sys.get_state(StatsServer)
    end

    test "tracks page views for multiple slugs" do
      start_supervised!(StatsServer)

      StatsServer.track_page_view("TESTSLUG")
      StatsServer.track_page_view("OTHERSLUG")
      assert %{"TESTSLUG" => 1, "OTHERSLUG" => 1} == :sys.get_state(StatsServer)

      StatsServer.track_page_view("OTHERSLUG")
      assert %{"TESTSLUG" => 1, "OTHERSLUG" => 2} == :sys.get_state(StatsServer)
    end
  end

  describe "handle_info - :persist_page_views" do
    test "persists page views for each slug" do
      Mox.expect(SlugGenerator.Mock, :generate, fn _ -> "TESTSLUG" end)
      Mox.expect(SlugGenerator.Mock, :generate, fn _ -> "OTHERSLUG" end)

      shortened_url = fixture(:shortened_url, %{page_views: 0})
      other_shortened_url = fixture(:shortened_url, %{page_views: 0})
      start_supervised!(StatsServer)

      StatsServer.track_page_view("TESTSLUG")
      StatsServer.track_page_view("OTHERSLUG")
      StatsServer.track_page_view("OTHERSLUG")

      send(StatsServer, :persist_page_views)
      wait_for_message_process!()

      shortened_url = Repo.reload(shortened_url)
      assert %ShortenedURL{page_views: 1} = shortened_url

      other_shortened_url = Repo.reload(other_shortened_url)
      assert %ShortenedURL{page_views: 2} = other_shortened_url
    end

    test "resets state" do
      start_supervised!(StatsServer)

      send(StatsServer, :persist_page_views)
      wait_for_message_process!()

      assert %{} == :sys.get_state(StatsServer)
    end

    test "schedules next update" do
      # speed up tests by temporarily setting update interval to 50
      switch_update_interval(50)

      stats_server_pid = start_supervised!(StatsServer)
      :erlang.trace(stats_server_pid, true, [:receive])

      send(StatsServer, :persist_page_views)
      wait_for_message_process!()

      assert_received {:trace, ^stats_server_pid, :receive, :persist_page_views}
    end
  end

  describe "terminate/2" do
    @tag slug_stub: "TESTSLUG"
    test "persists page views before terminating" do
      shortened_url = fixture(:shortened_url, %{page_views: 0})
      start_supervised!(StatsServer)

      StatsServer.track_page_view("TESTSLUG")

      stop_supervised!(StatsServer)

      shortened_url = Repo.reload(shortened_url)
      assert %ShortenedURL{page_views: 1} = shortened_url
    end
  end

  # Ensure async processes that update the db finish before proceeding
  defp wait_for_message_process! do
    stats_server_pid = Process.whereis(StatsServer)
    :erlang.trace(stats_server_pid, true, [:receive])
    assert_receive {:trace, ^stats_server_pid, :receive, {_ref, :persisted}}, 500
  end

  defp switch_update_interval(new_interval) do
    current_update_interval = Application.get_env(:shortener, :stats_server_persist_interval)
    Application.put_env(:shortener, :stats_server_persist_interval, new_interval)

    on_exit(fn ->
      Application.put_env(:shortener, :stats_server_persist_interval, current_update_interval)
    end)
  end
end
