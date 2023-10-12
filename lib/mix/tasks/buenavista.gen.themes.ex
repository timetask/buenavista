defmodule Mix.Tasks.Buenavista.Gen.Themes do
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "(Re)Generates Nomenclator and Hydrator modules"
  def run(opts) do
    {parsed_opts, _, _} = OptionParser.parse(opts, strict: [core: :boolean])

    themes = get_themes(parsed_opts)

    BuenaVista.Generator.generate_theme_files(themes)
  end

  defp get_themes(parsed_opts) do
    if Keyword.get(parsed_opts, :core, false),
      do: get_core_themes(),
      else: BuenaVista.Themes.get_themes() |> filter_by_name(parsed_opts)
  end

  defp filter_by_name(themes, parsed_opts) do
    theme_names = Keyword.get_values(parsed_opts, :theme)

    if Enum.empty?(theme_names),
      do: themes,
      else: Enum.filter(themes, fn theme -> theme.name in theme_names end)
  end

  defp get_core_themes() do
    config = [
      apps: [
        [name: :buenavista_galeria]
      ],
      config: [
        base_module: BuenaVista.Themes,
        extend: :hydrator,
        themes_dir: "lib/themes",
        hydrator_imports: [
          BuenaVista.Constants.TailwindColors,
          BuenaVista.Constants.TailwindSizes
        ]
      ],
      themes: [
        [name: "default", output: false]
      ]
    ]

    BuenaVista.ConfigReader.build_themes(config)
  end
end
