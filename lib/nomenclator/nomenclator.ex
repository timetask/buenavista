defmodule BuenaVista.Nomenclator do
  @callback __class_name(atom(), atom(), atom()) :: String.t() | nil
  @optional_callbacks __class_name: 3

  defmacro __using__(_opts) do
    quote do
      @behaviour BuenaVista.Nomenclator

      def class_name(component, :classes, :base_class) do
        classname = __MODULE__.__class_name(component, :classes, :base_class)

        if classname == :not_implemented,
          do: Atom.to_string(component) |> String.replace("_", "-"),
          else: classname
      end

      def class_name(component, :classes, class_key) do
        classname = __MODULE__.__class_name(component, :classes, class_key)

        if classname == :not_implemented,
          do: Atom.to_string(class_key) |> String.replace("_class", "") |> String.replace("_", "-"),
          else: classname
      end

      def class_name(component, variant, option) do
        classname = __MODULE__.__class_name(component, variant, option)

        if classname == :not_implemented,
          do: option |> Atom.to_string() |> String.replace("_", "-"),
          else: classname
      end
    end
  end
end
