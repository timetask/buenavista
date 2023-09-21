defmodule Mix.Tasks.Bv.Gen.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    {parsed_opts, _, _} = OptionParser.parse(opts, strict: [core: :boolean, bundle: :keep], aliases: [b: :bundle])

    parsed_opts
    |> get_bundles()
    |> maybe_filter_bundles_by_name(parsed_opts)
    |> BuenaVista.Generator.sync_config()
  end

  defp get_bundles(parsed_opts) do
    if Keyword.get(parsed_opts, :core, false),
      do: get_core_bundles(),
      else: BuenaVista.Config.get_bundles()
  end

  defp maybe_filter_bundles_by_name(bundles, parsed_opts) do
    filter_bundle_names = Keyword.get_values(parsed_opts, :bundle)

    if Enum.empty?(filter_bundle_names),
      do: bundles,
      else: Enum.filter(bundles, fn bundle -> bundle.name in filter_bundle_names end)
  end

  defp get_core_bundles() do
    bundles = [
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

    for bundle <- bundles, do: BuenaVista.Helpers.build_bundle(bundle)
  end
end
