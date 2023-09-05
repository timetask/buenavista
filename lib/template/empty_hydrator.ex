defmodule BuenaVista.Template.EmptyHydrator do
  @behaviour BuenaVista.Hydrator

  def variables(), do: []

  def css(_component, _variant, _option), do: ""
end
