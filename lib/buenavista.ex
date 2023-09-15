defmodule BuenaVista do
  defdelegate current_nomenclator(), to: BuenaVista.Config

  # Button
  defdelegate button(assigns), to: BuenaVista.Components.Button

  # Input
  defdelegate label(assigns), to: BuenaVista.Components.Input
  defdelegate input_group(assigns), to: BuenaVista.Components.Input
  defdelegate input(assigns), to: BuenaVista.Components.Input

  # Layout
  defdelegate sidebar_layout(assigns), to: BuenaVista.Components.Layout

  # Navigation
  defdelegate navigation(assigns), to: BuenaVista.Components.Navigation
  defdelegate navigation_item(assigns), to: BuenaVista.Components.Navigation

  # Text
  defdelegate heading(assigns), to: BuenaVista.Components.Typography
end
