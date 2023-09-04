defmodule BuenaVista.Nomenclator.Default do
  use BuenaVista.Nomenclator

  def class_name(:button, :border, :none), do: nil
  def class_name(:button, :border, option), do: "button-border-#{option}"

  def class_name(:label, :state, :default), do: nil
end
