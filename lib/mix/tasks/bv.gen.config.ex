defmodule Mix.Tasks.Bv.Gen.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    {parsed, _, _} = OptionParser.parse(opts, strict: [core: :boolean])

    bundles =
      if Keyword.get(parsed, :core, false),
        do: get_core_bundles(),
        else: BuenaVista.Config.get_bundles()

    BuenaVista.Generator.sync_config(bundles)
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
