defmodule BuenaVista.Nomenclator do
  @callback class_name(atom(), atom(), atom()) :: String.t() | nil
  @optional_callbacks class_name: 3
end
