defmodule Mix.Tasks.Buenavista.Gen.Config do
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
        do: BuenaVista.Config.get_bundles(),
        else: get_core_bundles()

    for %BuenaVista.Bundle{} = bundle <- bundles do
      BuenaVista.Generator.sync_config(bundle)

      if match?(%BuenaVista.Bundle.Nomenclator{}, bundle.nomenclator) do
        unless function_exported?(bundle.nomenclator.module_name, :__info__, 1) do
          Code.compile_file(bundle.nomenclator.file)
        end
      end

      if match?(%BuenaVista.Bundle.Hydrator{}, bundle.hydrator) do
        unless function_exported?(bundle.hydrator.module_name, :__info__, 1) do
          Code.compile_file(bundle.hydrator.file)
        end
      end
    end
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
          out_dir: "lib/template"
        ],
        css: nil
      ]
    ]

    for bundle <- bundles, do: BuenaVista.Helpers.build_bundle(bundle)
  end
end
