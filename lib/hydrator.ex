defmodule BuenaVista.Hydrator do
  @callback variables() :: list()
  @callback css(atom(), atom(), atom()) :: String.t()

  @optional_callbacks css: 3

  defmacro __using__(_opts) do
    quote do
      @behaviour BuenaVista.Hydrator

      def variables(), do: []

      def hydrate_css(component, variant, option) do
        try do
          __MODULE__.css(component, variant, option)
        rescue
          _e in [UndefinedFunctionError, FunctionClauseError] ->
            variables = __MODULE__.__info__(:attributes)

            if parent = Keyword.get(variables, :parent) do
              parent.hydrate_css(component, variant, option)
            else
              ""
            end
        end
      end
    end
  end
end
