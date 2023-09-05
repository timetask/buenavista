defmodule BuenaVista.Config do
  def get_current_nomenclator() do
    BuenaVista.Template.DefaultNomenclator
  end
  

  def get_available_bundles() do
    Application.get_env(:buenavista, :bundles)
  end
end
