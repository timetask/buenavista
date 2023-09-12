defmodule Mix.Tasks.Buenavista.Sync.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(_opts) do
    for %BuenaVista.Bundle{} = bundle <- BuenaVista.Config.get_bundles() do
      BuenaVista.Generator.sync(bundle)

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
end
