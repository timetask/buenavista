defmodule Mix.Tasks.Buenavista.Gen.Css do
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(opts) do
    {parsed_opts, _, _} = OptionParser.parse(opts, strict: [theme: :keep])

    themes = BuenaVista.Themes.get_themes() |> filter_by_name(parsed_opts)

    BuenaVista.Generator.generate_css_files(themes)
  end

  defp filter_by_name(themes, parsed_opts) do
    theme_names = Keyword.get_values(parsed_opts, :theme)

    if Enum.empty?(theme_names),
      do: themes,
      else: Enum.filter(themes, fn theme -> theme.name in theme_names end)
  end
end
