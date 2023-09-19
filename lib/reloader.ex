defmodule BuenaVista.Reloader do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, _watcher_pid, {_path, events}}, state) do
    # Your own logic for path and events
    if :modified in events do
      # on_change = Application.get_env(:buenavista, :on_change_callback)
      System.cmd("mix", ["bv.rebuild"])
      # on_change.()
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    # dbg(watcher_pid)
    {:noreply, state}
  end
end
