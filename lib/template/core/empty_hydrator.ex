defmodule BuenaVista.Template.EmptyHydrator do
  use BuenaVista.Hydrator

  variable :sidebar_width, "30px"

  def css(_component, _variant, _option), do: ""
end
