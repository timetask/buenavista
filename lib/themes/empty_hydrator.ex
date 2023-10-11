defmodule BuenaVista.Themes.EmptyHydrator do
  use BuenaVista.Hydrator

  def css(_component, _variant, _option, _variables), do: ""

  def class_name(_component, _variant, _option), do: nil
end
