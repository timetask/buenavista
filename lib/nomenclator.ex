defmodule BuenaVista.Nomenclator do
  @callback class_name(atom(), atom(), atom()) :: String.t() | nil
  @optional_callbacks class_name: 3

  def __before_compile__(env) do
    {_, :def, _, defs} = Module.get_definition(env.module, {:class_name, 3})

    defs =
      for class_name_def <- defs, reduce: %{} do
        acc ->
          case class_name_def do
            {_, [component, variant, option], [], class_name}
            when is_atom(component) and is_atom(variant) and is_atom(option) and is_binary(class_name) ->
              Map.put(acc, {component, variant, option}, class_name)

            _ ->
              acc
          end
      end

    Module.put_attribute(env.module, :__defs_class_name__, defs)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour BuenaVista.Nomenclator
      @before_compile BuenaVista.Nomenclator
      Module.register_attribute(__MODULE__, :__defs_class_name__, persist: true)

      def get_class_name_defs() do
        [defs] = :attributes |> __MODULE__.__info__() |> Keyword.get(:__defs_class_name__)
        defs
      end
    end
  end
end
