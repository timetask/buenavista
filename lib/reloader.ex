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
    if :modified in events do
      Logger.info("reloading css files...")
      BuenaVista.Generator.generate_css_files()
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end
end
