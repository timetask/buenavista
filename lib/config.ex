defmodule BuenaVista.Config do
  alias BuenaVista.Helpers

  @default_bundle_name Application.compile_env(:buenavista, :default_bundle)

  @bundles (for bundle <- Application.compile_env(:buenavista, :bundles) || [] do
              Helpers.build_bundle(bundle)
            end)

  def get_bundles(), do: @bundles

  def find_bundle(bundle_name) when is_binary(bundle_name) do
    Enum.find(get_bundles(), fn bundle -> bundle.name == bundle_name end)
  end

  def get_default_bundle() do
    find_bundle(@default_bundle_name)
  end

  def current_nomenclator() do
    BuenaVista.Template.DefaultNomenclator
  end

  def available_bundles() do
    Application.get_env(:buenavista, :bundles)
  end

  def gettext() do
    Application.get_env(:buenvista, :gettext)
  end
end
