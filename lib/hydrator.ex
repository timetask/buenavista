defmodule BuenaVista.Hydrator do
  @callback variables() :: list()
  @callback css(atom(), atom(), atom()) :: String.t()

  @optional_callbacks css: 3
end
