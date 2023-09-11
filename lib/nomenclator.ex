defmodule BuenaVista.Nomenclator do
  @callback class_name(atom(), atom(), atom()) :: String.t() | nil
  @optional_callbacks class_name: 3

  def __before_compile__(env) do
    if defs = Module.get_definition(env.module, {:class_name, 3}) do
      {_, :def, _, defs} = defs

      class_names =
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

      Module.put_attribute(env.module, :class_names, class_names)
    end
  end

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @behaviour BuenaVista.Nomenclator
      @before_compile BuenaVista.Nomenclator

      Module.register_attribute(__MODULE__, :class_names, persist: true)
      Module.register_attribute(__MODULE__, :parent, persist: true)
      Module.put_attribute(__MODULE__, :parent, Keyword.get(opts, :parent))

      def get_class_names() do
        case :attributes |> __MODULE__.__info__() |> Keyword.get(:class_names) do
          [defs] -> defs
          _ -> %{}
        end
      end
    end
  end
end
