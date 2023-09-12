defmodule BuenaVista.Template.EmptyHydrator do
  use BuenaVista.Hydrator

  def css(_component, _variant, _option, _variables), do: ""
end
