defmodule BuenaVista.Hydrator do
  defmodule Variable do
    defstruct [:key, :css_key, :css_value, :property, :parent]
  end

  defmodule Style do
    defstruct [:key, :css, :parent]
  end

  defmacro var(key, value) when is_atom(key) do
    quote bind_quoted: [key: key, value: value] do
      css_key = var_key_to_css_name(key)

      {css_value, property} =
        case value do
          {raw_body, formatted_code} ->
            css_value =
              Regex.replace(
                ~r/#\{([^{}]*)\}/,
                formatted_code,
                fn _, func ->
                  {css_value, []} = Code.eval_string(func, [], __ENV__)
                  css_value
                end,
                global: true
              )

            {css_value, %{type: :var, raw_body: raw_body}}

          css_value when is_binary(css_value) ->
            {css_value, %{type: :raw_value}}

          css_value when is_atom(css_value) ->
            {Atom.to_string(css_value), %{type: :raw_value}}

          css_value when is_integer(css_value) ->
            {Integer.to_string(css_value), %{type: :raw_value}}
        end

      var_def = %Variable{key: key, css_key: css_key, css_value: css_value, property: property}

      Module.put_attribute(__MODULE__, :__var_defs__, var_def)
    end
  end

    def typeof(a) do
        cond do
            is_float(a)    -> "float"
            is_number(a)   -> "number"
            is_atom(a)     -> "atom"
            is_boolean(a)  -> "boolean"
            is_binary(a)   -> "binary"
            is_function(a) -> "function"
            is_list(a)     -> "list"
            is_tuple(a)    -> "tuple"
            true           -> "idunno"
        end    
    end

  defmacro style(path, css) when is_list(path) do
    quote bind_quoted: [path: path, css: css] do
      key = if is_tuple(path), do: path, else: List.to_tuple(path)
      style_def = %Style{key: key, css: css}

      Module.put_attribute(__MODULE__, :__style_defs__, style_def)
    end
  end

  def __before_compile__(env) do
    parent = Module.get_attribute(env.module, :parent)
    local_variables = Module.get_attribute(env.module, :__var_defs__)

    local_variables = Enum.reverse(local_variables)

    variables =
      if is_nil(parent) do
        for var <- local_variables, reduce: [] do
          acc -> Keyword.put(acc, var.key, %{var | parent: false})
        end
      else
        parent_vars =
          for {key, var} <- parent.get_variables() do
            {key, %{var | parent: true}}
          end

        for %Variable{} = var <- local_variables, reduce: parent_vars do
          acc ->
            if Keyword.has_key?(acc, var.key) do
              Keyword.replace(acc, var.key, %{var | parent: false})
            else
              Keyword.put(acc, var.key, %{var | parent: false})
            end
        end
      end

    # Stored in reverse so that group_by re sorts them
    Module.put_attribute(env.module, :variables, variables)

    local_styles = Module.get_attribute(env.module, :__style_defs__)

    styles =
      if is_nil(parent) do
        for %Style{} = style <- local_styles, into: %{} do
          {style.key, %{style | parent: false}}
        end
      else
        parent_map =
          for {key, style} <- parent.get_styles_map(), into: %{} do
            {key, %{style | parent: true}}
          end

        for %Style{} = style <- local_styles, reduce: parent_map do
          style_map ->
            Map.put(style_map, style.key, %{style | parent: false})
        end
      end

    Module.put_attribute(env.module, :styles, styles)
  end

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @before_compile BuenaVista.Hydrator

      import BuenaVista.Hydrator
      import BuenaVista.CssSigils

      Module.register_attribute(__MODULE__, :__var_defs__, accumulate: true)
      Module.register_attribute(__MODULE__, :__style_defs__, accumulate: true)

      Module.register_attribute(__MODULE__, :variables, persist: true)
      Module.register_attribute(__MODULE__, :styles, persist: true)

      Module.register_attribute(__MODULE__, :parent, persist: true)
      Module.put_attribute(__MODULE__, :parent, Keyword.get(opts, :parent, nil))

      Module.register_attribute(__MODULE__, :nomenclator, persist: true)
      Module.put_attribute(__MODULE__, :nomenclator, Keyword.get(opts, :nomenclator, nil))

      def css(component, variant, option, variables) do
        case Map.get(get_styles_map(), {component, variant, option}) do
          %Style{} = style ->
            css_template = "<% import #{inspect(__MODULE__)}, only: [class_name: 3]%>" <> style.css
            EEx.eval_string(css_template, assigns: variables)

          _ ->
            if is_nil(@parent),
              do: raise("Unhandled style definiton :#{component} :#{variant} :#{option} in #{__MODULE__}"),
              else: @parent.css(component, variant, option, variables)
        end
      end

      def class_name(component, variant, option) do
        if is_nil(@nomenclator),
          do: raise("Can't call class_name/3 inside #{inspect(__MODULE__)} without setting a nomenclator"),
          else: @nomenclator.class_name(component, variant, option)
      end

      defoverridable css: 4, class_name: 3

      def get_variables() do
        case :attributes |> __MODULE__.__info__() |> Keyword.get(:variables) do
          variables when is_list(variables) -> variables
          _ -> []
        end
      end

      def get_styles_map() do
        [styles_map] =
          :attributes
          |> __MODULE__.__info__()
          |> Keyword.get(:styles)

        styles_map
      end
    end
  end

  def var_key_to_css_name(key) do
    key
    |> Atom.to_string()
    |> String.replace("_", "-")
  end
end
