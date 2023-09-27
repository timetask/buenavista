defmodule Mix.Tasks.Bv.Gen.Css do
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @component_apps Application.compile_env(:buenavista, :apps)

  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(_opts) do
    apps = @component_apps
    themes = BuenaVista.Config.get_themes()

    BuenaVista.Generator.generate_css_files(themes, @component_apps)
  end
end
