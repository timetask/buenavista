defmodule BuenaVista.Config do
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
