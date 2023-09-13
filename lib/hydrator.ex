defmodule BuenaVista.Hydrator do
  defmodule Variable do
    defstruct [:key, :css_key, :css_value, :parent]
  end

  defmodule Style do
    defstruct [:key, :css, :parent]
  end

  defmacro variable(key, value) when is_atom(key) and is_binary(value) do
    quote bind_quoted: [key: key, value: value] do
      css_key = var_key_to_css_name(key)
      var_def = %Variable{key: key, css_key: css_key, css_value: value}

      Module.put_attribute(__MODULE__, :__var_defs__, var_def)
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

    variables =
      if is_nil(parent) do
        for var <- local_variables, reduce: :gb_trees.empty() do
          tree ->
            :gb_trees.insert(var.key, var, tree)
        end
      else
        parent_tree =
          :gb_trees.map(
            fn _k, var -> %{var | parent: true} end,
            parent.get_variables_tree()
          )

        for var <- local_variables, reduce: parent_tree do
          tree ->
            :gb_trees.enter(var.key, %{var | parent: false}, tree)
        end
      end

    Module.put_attribute(env.module, :variables, variables)

    styles = Module.get_attribute(env.module, :__style_defs__)
    Module.put_attribute(env.module, :styles, styles)
  end

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @before_compile BuenaVista.Hydrator
      import BuenaVista.Hydrator
      import BuenaVista.CssSigil

      Module.register_attribute(__MODULE__, :__var_defs__, accumulate: true)
      Module.register_attribute(__MODULE__, :__style_defs__, accumulate: true)

      Module.register_attribute(__MODULE__, :variables, persist: true)
      Module.register_attribute(__MODULE__, :styles, persist: true)

      Module.register_attribute(__MODULE__, :parent, persist: true)
      Module.put_attribute(__MODULE__, :parent, Keyword.get(opts, :parent, nil))

      def css(component, variant, option, variables) do
        case Map.get(get_computed_styles(), {component, variant, option}) do
          %Style{} = style ->
            EEx.eval_string(style.css, assigns: variables)

          _ ->
            if is_nil(@parent),
              do: raise("Unhandled style definiton :#{component} :#{variant} :#{option} in #{__MODULE__}"),
              else: @parent.css(component, variant, option, variables)
        end
      end

      defoverridable css: 4

      def get_variables_tree() do
        [variables_tree] =
          :attributes
          |> __MODULE__.__info__()
          |> Keyword.get(:variables)

        variables_tree
      end

      def get_variables_list() do
        :gb_trees.to_list(get_variables_tree())
      end

      def get_styles(parent \\ false) do
        module_styles =
          :attributes
          |> __MODULE__.__info__()
          |> Keyword.get(:styles)
      end

      def get_computed_styles(parent \\ false) do
        module_styles = for style <- get_styles(), into: %{}, do: {style.key, %{style | parent: parent}}

        if is_nil(@parent) do
          module_styles
        else
          parent_styles = @parent.get_computed_styles(true)
          Map.merge(parent_styles, module_styles)
        end
      end
    end
  end

  def var_key_to_css_name(key) do
    key
    |> Atom.to_string()
    |> String.replace("_", "-")
  end
end
