defmodule Mix.Tasks.Buenavista.Gen.Css do
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(_opts) do
    BuenaVista.Generator.generate_css_files()
  end
end
