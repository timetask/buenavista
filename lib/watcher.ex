defmodule BuenaVista.Watcher do
  use Application
  require Logger

  def start(_, _) do
    dbg("start watcher")
    :ok
  end

  def run(app, dirs) when is_atom(app) and is_list(dirs) do
    opts = [
      cd: File.cwd!(),
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: false
    ]

    dirs =
      for dir <- dirs do
        abs_path = File.cwd!() |> Path.join(dir) |> Path.expand()
        "--watch=#{abs_path}"
      end

    Logger.info("Adding watchexec for assets.build.#{app}\n #{Enum.join(dirs, "\n ")}")

    args = [dirs, "-e ex", "--verbose", "--notify", "mix css.build.#{app}"] |> List.flatten()

    System.cmd("watchexec", args, opts)
  end
end
