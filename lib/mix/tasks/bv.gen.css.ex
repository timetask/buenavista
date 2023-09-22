defmodule Mix.Tasks.Bv.Gen.Css do
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(opts) do
    {parsed, _, _} = OptionParser.parse(opts, strict: [theme: :keep], aliases: [t: :theme])

    BuenaVista.Config.get_themes()
    |> maybe_filter_themes_by_name(parsed)
    |> BuenaVista.Generator.generate_css_files()
  end

  defp maybe_filter_themes_by_name(themes, parsed_opts) do
    filter_theme_names = Keyword.get_values(parsed_opts, :theme)

    if Enum.empty?(filter_theme_names),
      do: themes,
      else: Enum.filter(themes, fn theme -> theme.name in filter_theme_names end)
  end
end
