defmodule BuenaVista.Template.EmptyNomenclator do
  @behaviour BuenaVista.Nomenclator

  def class_name(_component, _variant, _name), do: ""
end
