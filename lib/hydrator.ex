defmodule BuenaVista.Hydrator do
  @callback variables() :: list()
  @callback css(atom(), atom(), atom()) :: String.t()

  @optional_callbacks variables: 0, css: 3

  def __before_compile__(env) do
    {_, :def, _, defs} = Module.get_definition(env.module, {:css, 3})

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

    Module.put_attribute(env.module, :__defs_css__, defs)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour BuenaVista.Hydrator
      @before_compile BuenaVista.Hydrator

      import BuenaVista.CSS

      Module.register_attribute(__MODULE__, :__defs_css__, persist: true)

      def get_css_defs() do
        [defs] = :attributes |> __MODULE__.__info__() |> Keyword.get(:__defs_css__)
        defs
      end
    end
  end
end
