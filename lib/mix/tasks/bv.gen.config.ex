defmodule Mix.Tasks.Bv.Gen.Config do
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @component_apps Application.compile_env(:buenavista, :apps)

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    {parsed_opts, _, _} = OptionParser.parse(opts, strict: [core: :boolean])

    apps = @component_apps
    themes = get_themes(parsed_opts)

    BuenaVista.Generator.generate_config_files(themes, apps)
  end

  defp get_themes(parsed_opts) do
    if Keyword.get(parsed_opts, :core, false),
      do: get_core_themes(),
      else: BuenaVista.Config.get_themes()
  end

  defp get_core_themes() do
    themes = [
      [
        name: "default",
        nomenclator: BuenaVista.Template.DefaultNomenclator,
        hydrator: [
          parent: BuenaVista.Template.EmptyHydrator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template",
          imports: [
            BuenaVista.Constants.DefaultColors,
            BuenaVista.Constants.DefaultSizes
          ]
        ],
        css: nil
      ]
    ]

    for theme <- themes, do: BuenaVista.Helpers.build_theme(theme)
  end
end
