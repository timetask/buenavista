defmodule Mix.Tasks.Buenavista.Sync.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  alias BuenaVista.Bundle
  alias BuenaVista.Generator

  @requirements ["app.config"]

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(_opts) do
    bundles = Application.get_env(:buenavista, :bundles)
    bundles = sanitize_bundles(bundles)

    for bundle <- bundles do
      Generator.sync(bundle)
    end
  end

  defp sanitize_bundles(bundles) when is_list(bundles) do
    for bundle <- bundles do
      unless is_list(bundle) do
        raise ":bundles config should a a list of keyword lists. Got: #{inspect(bundle)}."
      end

      name =
        Keyword.get(bundle, :name) ||
          raise "Bundle config error: missing key :name. Provided bundle: #{inspect(bundle)}"

      parent_hydrator = Keyword.get(bundle, :parent_hydrator)

      parent_nomenclator =
        Keyword.get(bundle, :parent_nomenclator, BuenaVista.Template.DefaultNomenclator) ||
          raise "Bundle config error: missing key :parent_nomenclator. Provided bundle: #{inspect(bundle)}"

      component_apps =
        Keyword.get(bundle, :component_apps) ||
          raise "Bundle config error: missing key :component_apps. Provided bundle: #{inspect(bundle)}"

      unless is_list(component_apps) do
        raise ":component_apps in bundle #{inspect(bundle)} must be a list of apps."
      end

      config_out_dir =
        Keyword.get(bundle, :config_out_dir) ||
          raise "Bundle config error: missing key :config_out_dir. Provided bundle: #{inspect(bundle)}"

      config_base_module =
        Keyword.get(bundle, :config_base_module) ||
          raise "Bundle config error: missing key :config_base_module. Provided bundle: #{inspect(bundle)}"

      produce_css =
        Keyword.get(bundle, :produce_css, true)

      unless produce_css in [true, false] do
        raise "Bundle config error: missing key :produce_css. Provided bundle: #{inspect(bundle)}"
      end

      %Bundle{
        name: name,
        parent_hydrator: parent_hydrator,
        parent_nomenclator: parent_nomenclator,
        component_apps: component_apps,
        config_out_dir: config_out_dir,
        config_base_module: config_base_module,
        produce_css: produce_css
      }
    end
  end

  defp sanitize_bundles(bundles) do
    Mix.raise("Bundle config error. Bundle config must be a list of lists. Got: #{inspect(bundles)}")
  end
end
