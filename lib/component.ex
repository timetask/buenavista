defmodule BuenaVista.Component do
  use Phoenix.Component
  use TypedStruct

  alias __MODULE__
  @reserved_class_names [:classes, :variant, :variants, :variant_classes, :base_class]

  # ----------------------------------------
  # Data Structures
  # ----------------------------------------
  defmodule Variant do
    typedstruct do
      field :name, String.t()
      field :options, list(atom())
      field :default, atom()
    end
  end

  typedstruct do
    field :app, atom()
    field :name, String.t()
    field :module, atom()
    field :variants, list(Variant.t())
    field :attrs, list(map())
    field :slots, list(map())
    field :classes, list(atom())
  end

  # ----------------------------------------
  # Macros
  # ----------------------------------------
  defmacro variant(name, options, default)
           when is_atom(name) and is_list(options) and is_atom(default) do
    quote bind_quoted: [name: name, options: options, default: default] do
      variant_def = %Variant{name: name, options: options, default: default}

      if default not in options do
        raise(ArgumentError,
          message: "default option #{default} must be one of the provided options #{inspect(options)}"
        )
      end

      Module.put_attribute(__MODULE__, :__variant_defs__, variant_def)

      Phoenix.Component.Declarative.__attr__!(
        __MODULE__,
        name,
        :atom,
        [values: options, default: default],
        __ENV__.line,
        __ENV__.file
      )
    end
  end

  defmacro classes(class_list) when is_list(class_list) do
    quote do
      Module.put_attribute(__MODULE__, :__classes_defs__, unquote(class_list))
    end
  end

  def __is_component?(component_name, args) do
    if component_name |> Atom.to_string() |> String.starts_with?("__") do
      false
    else
      match?([{_, _, [:def, {:var!, _, [{:assigns, _, _}]}]}], args)
    end
  end

  def __on_definition__(env, _kind, component_name, args, _guards, _body) do
    if __is_component?(component_name, args) do
      nomenclator = BuenaVista.current_nomenclator()

      variant_defs = Module.delete_attribute(env.module, :__variant_defs__) || []
      variant_defs = Enum.reverse(variant_defs)

      classes_defs = Module.delete_attribute(env.module, :__classes_defs__) || []
      classes = classes_defs |> Enum.reverse() |> List.flatten()

      variants =
        for %Variant{} = variant <- variant_defs do
          options =
            for option <- variant.options do
              class_name = nomenclator.class_name(component_name, variant.name, option)
              {option, class_name}
            end

          %{variant | options: options}
        end

      for class_name <- classes, class_name in @reserved_class_names do
        raise "#{class_name} is a reserved word. Please use another class name"
      end

      classes =
        for class_key <- [:base_class | classes] do
          class_name = nomenclator.class_name(component_name, :classes, class_key)
          {class_key, class_name}
        end

      phoenix_components = Map.get(Module.get_attribute(env.module, :__components__), component_name)

      excluded_names = for variant <- variants, do: variant.name
      excluded_names = [:nomenclator | excluded_names]

      attrs =
        phoenix_components
        |> Map.get(:attrs)
        |> Enum.reject(fn attr ->
          attr.name in excluded_names or attr.type == :global
        end)

      app = Application.get_application(env.module)

      component = %Component{
        app: app,
        name: component_name,
        variants: variants,
        classes: classes,
        module: env.module,
        attrs: attrs,
        slots: phoenix_components.slots
      }

      Module.put_attribute(env.module, :__bv_components__, {component.name, component})
    end

    :ok
  end

  # ----------------------------------------
  # Persist Module Attribute
  # ----------------------------------------
  def __before_compile__(env) do
    components = Module.get_attribute(env.module, :__bv_components__)
    Module.put_attribute(env.module, :buenavista, components)
  end

  defmacro component(head, do: body) do
    {fn_name, _assigns} = Macro.decompose_call(head)

    quote do
      attr :nomenclator, :atom, default: nil

      def unquote(fn_name)(var!(assigns)) do
        nomenclator = Map.get(var!(assigns), :nomenclator)

        %Component{} = component = __buenavista_component(unquote(fn_name))

        var!(assigns) =
          var!(assigns)
          |> __assign_variant_classes(component, nomenclator)
          |> __assign_classes(component, nomenclator)

        unquote(body)
      end
    end
  end

  # ----------------------------------------
  # Code Injection
  # ----------------------------------------
  defmacro __using__(_opts \\ []) do
    quote do
      use Phoenix.Component
      import BuenaVista.Component

      @on_definition BuenaVista.Component
      @before_compile BuenaVista.Component

      Module.register_attribute(__MODULE__, :__variant_defs__, accumulate: true)
      Module.register_attribute(__MODULE__, :__classes_defs__, accumulate: true)
      Module.register_attribute(__MODULE__, :__bv_components__, accumulate: true)
      Module.register_attribute(__MODULE__, :buenavista, persist: true)

      def __are_you_buenavista?(), do: :yes

      def __buenavista_components() do
        :attributes
        |> __MODULE__.__info__()
        |> Keyword.get(:buenavista)
      end

      def __buenavista_component(component) do
        components = __MODULE__.__buenavista_components()
        Keyword.get(components, component)
      end

      def __assign_variant_classes(assigns, %Component{} = component, nomenclator) do
        classes =
          for %Variant{} = variant <- component.variants do
            selected_option = Map.get(assigns, variant.name)

            if not is_nil(selected_option) and
                 selected_option not in Keyword.keys(variant.options) do
              raise "Invalid BuenaVista component variant selected option:\n" <>
                      "\t\t> Module: #{inspect(__MODULE__)}\n" <>
                      "\t\t> Component: #{component.name}\n" <>
                      "\t\t> Variant: #{variant.name}\n" <>
                      "\t\t> Available options: #{inspect(Keyword.keys(variant.options))}\n" <>
                      "\t\t> Selected option: #{inspect(selected_option)}"
            end

            case {nomenclator, selected_option} do
              {nil, nil} ->
                Keyword.get(variant.options, variant.default)

              {nil, selected_option} ->
                Keyword.get(variant.options, selected_option)

              {nomenclator, nil} ->
                nomenclator.class_name(component.name, variant.name, variant.default)

              {nomenclator, selected_option} ->
                nomenclator.class_name(component.name, variant.name, selected_option)
            end
          end

        assign(assigns, :variant_classes, join_classes(classes))
      end

      def __assign_classes(assigns, %Component{} = component, nomenclator) do
        for {class_key, class_name} <- component.classes, reduce: assigns do
          assigns ->
            class_name =
              if is_nil(nomenclator),
                do: class_name,
                else: nomenclator.class_name(component.name, :classes, class_key)

            assign(assigns, class_key, class_name)
        end
      end
    end
  end

  # ----------------------------------------
  # Helpers
  # ----------------------------------------
  def join_classes(class_list) when is_binary(class_list), do: class_list

  def join_classes(class_list) when is_list(class_list) do
    class_list
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(&(!!&1 && &1 != ""))
    |> Enum.join(" ")
    |> case do
      "" -> nil
      classes -> classes
    end
  end
end
