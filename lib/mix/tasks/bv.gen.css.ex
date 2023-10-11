defmodule Mix.Tasks.Bv.Gen.Css do
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @component_apps Application.compile_env(:buenavista, :apps)

  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(opts) do
    {parsed_opts, _, _} = OptionParser.parse(opts, strict: [theme: :keep])

    themes = BuenaVista.Themes.get_themes() |> filter_by_name(parsed_opts)
    apps = @component_apps

    BuenaVista.Generator.generate_css_files(themes, apps)
  end

  defp filter_by_name(themes, parsed_opts) do
    theme_names = Keyword.get_values(parsed_opts, :theme)

    if Enum.empty?(theme_names),
      do: themes,
      else: Enum.filter(themes, fn theme -> theme.name in theme_names end)
  end
end
