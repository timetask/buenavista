defmodule Mix.Tasks.Buenavista.Sync.Config do
  @moduledoc """

  """
  use Mix.Task

  alias BuenaVista.Generator

  @requirements ["app.config"]
  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    # {parsed, _args, _errors} =
    #   OptionParser.parse(opts,
    #     aliasses: [n: :name, s: :style, o: :out, h: :help],
    #     strict: [name: :string, style: :string, out: :string, help: :boolean]
    #   )

    bundles = Application.get_env(:buenavista, :bundles)

    if is_list(bundles) do
      bundles =
        for bundle <- bundles do
          unless is_list(bundle) do
            raise ":bundles config should a a list of keyword lists. Got: #{inspect(bundle)}."
          end

          component_apps =
            Keyword.get(bundle, :component_apps) || raise "Bundle #{inspect(bundle)} is missing :component_apps."

          config_base_module =
            Keyword.get(bundle, :config_base_module) || raise "Bundle #{inspect(bundle)} is missing :config_base_module"

          config_dir = Keyword.get(bundle, :config_dir) || raise "Bundle #{inspect(bundle)} is missing :config_dir."
          style = Keyword.get(bundle, :style)
          name = Keyword.get(bundle, :name) || raise "Bundle #{inspect(bundle)} is missing :name."
          out_dir = Keyword.get(bundle, :out_dir) || raise "Bundle #{inspect(bundle)} is missing :out_dir."

          unless is_list(component_apps) do
            raise ":component_apps in bundle #{inspect(bundle)} must be a list of apps."
          end

          unless style in [:tailwind_inline, :tailwind_classes, :bootstrap, :vanilla_dark, :vanilla_light] do
            raise "Bundle #{inspect(bundle)} is missing a valid :style."
          end

          [component_apps: component_apps, config_dir: config_dir, style: style, name: name, out_dir: out_dir]
        end

      for bundle <- bundles do
        Generator.sync(bundle)
      end
    else
      Logger.error("Please provide a valid application :bundles config.")
      IO.puts(@moduledoc)
    end
  end
end
