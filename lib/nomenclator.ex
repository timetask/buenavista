defmodule BuenaVista.Nomenclator do
  @callback class_name(atom(), atom(), atom()) :: String.t() | nil
  @optional_callbacks class_name: 3

  defmacro __using__(_opts) do
    quote do
      @behaviour BuenaVista.Nomenclator

      def get_class_name(component, variant, option) do
        try do
          if component == :label and variant == :state do
            __MODULE__.class_name(component, variant, option)
          end

          __MODULE__.class_name(component, variant, option)
        rescue
          _e in [UndefinedFunctionError, FunctionClauseError] ->
            variables = __MODULE__.__info__(:attributes)

            if parent = Keyword.get(variables, :parent) do
              parent.get_class_name(component, variant, option)
            else
              default_class_name(component, variant, option)
            end
        end
      end

      defp default_class_name(component, :classes, :base_class) do
        component |> Atom.to_string() |> String.replace("_", "-")
      end

      defp default_class_name(_component, :classes, class_key) do
        class_key |> Atom.to_string() |> String.replace("_class", "") |> String.replace("_", "-")
      end

      defp default_class_name(component, _variant, option) do
        component = component |> Atom.to_string() |> String.replace("_", "-")
        option = option |> Atom.to_string() |> String.replace("_", "-")

        "#{component}-#{option}"
      end
    end
  end
end
