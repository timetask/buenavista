defmodule BuenaVista.Hydrator do
  @callback variables() :: list()
  @callback css(atom(), atom(), atom()) :: String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour BuenaVista.Hydrator

      def variables(), do: []

      def css(component_name, variant, option)
          when is_atom(component_name) and is_atom(variant) and is_atom(option) do
        ""
      end

      defoverridable variables: 0, css: 3
    end
  end
end
