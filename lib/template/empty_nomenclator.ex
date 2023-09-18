defmodule BuenaVista.Template.EmptyNomenclator do
  use BuenaVista.Nomenclator

  def class_name(_component, _variant, _name), do: ""
end
