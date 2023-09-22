defmodule Mix.Tasks.Bv.Gen.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    {parsed_opts, _, _} = OptionParser.parse(opts, strict: [core: :boolean, theme: :keep], aliases: [t: :theme])

    parsed_opts
    |> get_themes()
    |> maybe_filter_themes_by_name(parsed_opts)
    |> BuenaVista.Generator.sync_config()
  end

  defp get_themes(parsed_opts) do
    if Keyword.get(parsed_opts, :core, false),
      do: get_core_themes(),
      else: BuenaVista.Config.get_themes()
  end

  defp maybe_filter_themes_by_name(themes, parsed_opts) do
    filter_theme_names = Keyword.get_values(parsed_opts, :theme)

    if Enum.empty?(filter_theme_names),
      do: themes,
      else: Enum.filter(themes, fn theme -> theme.name in filter_theme_names end)
  end

  defp get_core_themes() do
    themes = [
      [
        name: "default",
        apps: [:buenavista],
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
