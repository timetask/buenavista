defmodule BuenaVista.Hydrator do
  defmodule Variable do
    defstruct [:key, :css_key, :css_value]
  end

  defmodule Style do
    defstruct [:key, :css]
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
    var_defs = Module.get_attribute(env.module, :__var_defs__)
    dbg(var_defs)
    # variables = for %Variable{} = variable <- var_defs, into: %{}, do: {variable.key, variable}
    Module.put_attribute(env.module, :variables, var_defs)

    style_defs = Module.get_attribute(env.module, :__style_defs__)
    styles = for %Style{} = style <- style_defs, into: %{}, do: {style.key, style}
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
      Module.put_attribute(__MODULE__, :parent, Keyword.get(opts, :parent))

      def get_variables() do
        :attributes
        |> __MODULE__.__info__()
        |> Keyword.get(:variables)
      end

      def get_styles() do
        [styles] =
          :attributes
          |> __MODULE__.__info__()
          |> Keyword.get(:styles)

        styles
      end
    end
  end

  def var_key_to_css_name(key) do
    key
    |> Atom.to_string()
    |> String.replace("_", "-")
  end
end
