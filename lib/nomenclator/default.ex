defmodule BuenaVista.Nomenclator.Default do
  use BuenaVista.Nomenclator

  def __class_name(:label, :state, :default), do: nil

  def __class_name(_, _, _), do: :not_implemented
end
