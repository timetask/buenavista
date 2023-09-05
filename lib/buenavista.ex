defmodule BuenaVista do
  defdelegate get_current_nomenclator(), to: BuenaVista.Config

  # Button
  defdelegate button(assigns), to: BuenaVista.Components.Button

  # Input
  defdelegate label(assigns), to: BuenaVista.Components.Input
  defdelegate input_group(assigns), to: BuenaVista.Components.Input
  defdelegate input(assigns), to: BuenaVista.Components.Input

  # Layout
  defdelegate sidebar_layout(assigns), to: BuenaVista.Components.Layout
end
