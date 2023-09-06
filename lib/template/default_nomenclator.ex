defmodule BuenaVista.Template.DefaultNomenclator do
  use BuenaVista.Nomenclator

  def class_name(:button, :border, :none), do: nil
  def class_name(:button, :border, option), do: "button-border-#{option}"

  def class_name(:label, :state, :default), do: nil

  def class_name(component, :classes, :base_class) do
    component |> Atom.to_string() |> String.replace("_", "-")
  end

  def class_name(_component, :classes, class_key) do
    class_key |> Atom.to_string() |> String.replace("_class", "") |> String.replace("_", "-")
  end

  def class_name(component, _variant, option) do
    component = component |> Atom.to_string() |> String.replace("_", "-")
    option = option |> Atom.to_string() |> String.replace("_", "-")

    "#{component}-#{option}"
  end
end
