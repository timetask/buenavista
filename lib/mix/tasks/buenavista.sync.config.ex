defmodule Mix.Tasks.Buenavista.Sync.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  alias BuenaVista.Generator

  @allowed_styles [
    :internal_hydrator,
    :external_hydrator,
    :css,
    :tailwind,
    :tailwind_inline,
    :bootstrap,
    :bulma,
    :foundation
  ]

  @requirements ["app.config"]
  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(_opts) do
    bundles = Application.get_env(:buenavista, :bundles)

    if is_list(bundles) do
      bundles =
        for bundle <- bundles do
          unless is_list(bundle) do
            raise ":bundles config should a a list of keyword lists. Got: #{inspect(bundle)}."
          end

          name =
            Keyword.get(bundle, :name) ||
              raise "Bundle #{inspect(bundle)} is missing :name."

          style = Keyword.get(bundle, :style)

          unless style in @allowed_styles do
            raise "Bundle #{inspect(bundle)} is missing a valid :style."
          end

          component_apps =
            Keyword.get(bundle, :component_apps) ||
              raise "Bundle #{inspect(bundle)} is missing :component_apps."

          unless is_list(component_apps) do
            raise ":component_apps in bundle #{inspect(bundle)} must be a list of apps."
          end

          config_out_dir =
            Keyword.get(bundle, :config_out_dir) ||
              raise "Bundle #{inspect(bundle)} is missing :config_out_dir."

          config_base_module =
            Keyword.get(bundle, :config_base_module) ||
              raise "Bundle #{inspect(bundle)} is missing :config_base_module."

          [
            name: name,
            style: style,
            component_apps: component_apps,
            config_out_dir: config_out_dir,
            config_base_module: config_base_module
          ]
        end

      for bundle <- bundles do
        Generator.sync(bundle)
      end
    else
      Logger.error("Please provide a valid :buenavista :bundles application config.")
      IO.puts(@moduledoc)
    end
  end
end
