defmodule BuenaVista.Themes.DefaultNomenclator do
  use BuenaVista.Nomenclator

  def class_name(_, _, :none), do: nil

  def class_name(_, :state, :default), do: nil

  def class_name(component, :border, option), do: "#{component}-border-#{option}"

  def class_name(:sidebar_layout, :position, :left), do: nil

  def class_name(component, :classes, :base_class) do
    component |> Atom.to_string() |> String.replace("_", "-")
  end

  def class_name(component, :classes, class_key) do
    class_key = class_key |> Atom.to_string() |> String.replace("_class", "")
    String.replace("#{component}-#{class_key}", "_", "-")
  end

  def class_name(component, _variant, option) do
    String.replace("#{component}-#{option}", "_", "-")
  end
end
