defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Bundle
  alias BuenaVista.Helpers
  alias BuenaVista.Hydrator.Variable

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def init(_app_name, _out_dir, _style, _name) do
    # style = Keyword.get(bundle, :style)
    # component_apps = Keyword.get(bundle, :component_apps)

    # modules = BuenaVista.ComponentFinder.find_component_modules()

    # generate_nomenclator(modules, app_name, out_dir, style, name)

    # if uses_hydrator?(style) do
    #   generate_hydrator(modules, app_name, out_dir, style, name)
    # end
  end

  def sync(%Bundle{} = bundle) do
    modules = Helpers.find_component_modules(bundle.apps)
    sync_nomenclator(bundle, modules)
    sync_hydrator(bundle, modules)
  end

  # ----------------------------------------
  # Core Functions
  # ----------------------------------------
  defp sync_nomenclator(%Bundle{} = bundle, modules) do
    if match?(%Bundle.Nomenclator{}, bundle.nomenclator) do
      assigns = [
        module_name: bundle.nomenclator.module_name,
        existing_class_names: existing_defs(bundle, :nomenclator)[:class_names],
        parent: bundle.nomenclator.parent,
        modules: modules
      ]

      dir = Path.dirname(bundle.nomenclator.file)

      unless File.exists?(dir) do
        create_directory(dir, force: true)
      end

      create_file(bundle.nomenclator.file, nomenclator_template(assigns), force: true)
      System.cmd("mix", ["format", bundle.nomenclator.file])
    end
  end

  defp sync_hydrator(%Bundle{} = bundle, modules) do
    if match?(%Bundle.Hydrator{}, bundle.hydrator) do
      assigns = [
        module_name: bundle.hydrator.module_name,
        variables: hydrator_variables(bundle),
        existing_styles: existing_defs(bundle, :hydrator)[:styles],
        parent: bundle.hydrator.parent,
        modules: modules
      ]

      dir = Path.dirname(bundle.hydrator.file)

      unless File.exists?(dir) do
        create_directory(dir, force: true)
      end

      create_file(bundle.hydrator.file, hydrator_template(assigns), force: true)
      System.cmd("mix", ["format", bundle.hydrator.file])
    end
  end

  def hydrator_variables(bundle) do
    parent_vars =
      if is_nil(bundle.hydrator.parent),
        do: [],
        else: bundle.hydrator.parent.get_variables()

    existing_vars = existing_defs(bundle, :hydrator)[:variables]

    variables = for %Variable{} = var <- parent_vars, do: {var.key, %{parent: var, current: nil}}

    for %Variable{} = variable <- existing_vars, reduce: variables do
      acc ->
        if entry = Keyword.get(acc, variable.key) do
          Keyword.replace(acc, variable.key, %{parent: Map.get(entry, :parent), current: variable})
        else
          Keyword.put(acc, variable.key, %{parent: nil, current: variable})
        end
    end
    |> Enum.sort_by(& &1)
  end

  defp existing_defs(bundle, :nomenclator) do
    if function_exported?(bundle.nomenclator.module_name, :__info__, 1),
      do: %{class_names: bundle.nomenclator.module_name.get_class_names()},
      else: %{class_names: %{}}
  end

  defp existing_defs(bundle, :hydrator) do
    if function_exported?(bundle.hydrator.module_name, :__info__, 1),
      do: %{variables: bundle.hydrator.module_name.get_variables(), styles: bundle.hydrator.module_name.get_styles()},
      else: %{variables: %{}, styles: %{}}
  end

  # ----------------------------------------
  # Templates
  # ----------------------------------------
  embed_template(:nomenclator, ~S/
  defmodule <%= Helpers.pretty_module(@module_name) %> do
    use BuenaVista.Nomenclator,<%= unless is_nil(@parent) do %>parent: <%= Helpers.pretty_module(@parent) %><% end %>

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
        <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          <%= class_name_def(component.name, :classes, class_key, @existing_class_names, @parent) %><% end %>
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            <%= class_name_def(component.name, variant.name, option, @existing_class_names, @parent) %><% end %>
      <% end %>
    <% end %>
  <% end %>
  <%= unless is_nil(@parent) do %>defdelegate class_name(component, variant, option), to: @parent<% end %>
  end
  /)

  embed_template(:hydrator, ~S/
  defmodule <%= Helpers.pretty_module(@module_name) %> do
    use BuenaVista.Hydrator<%= unless is_nil(@parent) do %>, parent: <%= Helpers.pretty_module(@parent) %><% end %>
   
    <%= for {_, variable} <- @variables do %>
      <%= variable_def(variable) %><% end %>

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
        <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          <%= style_def(component.name, :classes, class_key, @existing_styles, @parent) %><% end %>
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            <%= style_def(component.name, variant.name, option, @existing_styles, @parent) %><% end %>
        <% end %>
      <% end %>
    <% end %>
  end
  /)

  defp style_def(component, variant, option, existing_styles, parent) do
    if style = Map.get(existing_styles, {component, variant, option}) do
      ~s/style [:#{component}, :#{variant}, :#{option}], ~CSS"""\n #{style.css} """/
    else
      ~s/# style [:#{component}, :#{variant}, :#{option}], ~CSS""" \n# #{parent && parent.css(component, variant, option) |> comment_lines()}"""/
    end
  end

  defp class_name_def(component, variant, option, existing_class_names, parent) do
    if class_name = Map.get(existing_class_names, {component, variant, option}) do
      ~s|def class_name(:#{component}, :#{variant}, :#{option}), do: "#{class_name}"|
    else
      ~s|# def class_name(:#{component}, :#{variant}, :#{option}), do: "#{parent && parent.class_name(component, variant, option)}"|
    end
  end

  def variable_def(variable) do
    case variable do
      %{parent: nil, current: nil} -> raise "weird"
      %{parent: parent, current: nil} -> ~s|# variable :#{parent.key}, "#{parent.css_value}"|
      %{parent: _parent, current: current} -> ~s|variable :#{current.key}, "#{current.css_value}"|
    end
  end

  defp comment_lines(content) do
    String.replace(content, "\n", "\n#")
  end

  embed_template(:module_title, ~S/
    # --------------------------------------------------------------------------------
    # <%= Helpers.pretty_module(@module) %>
    # --------------------------------------------------------------------------------
  /)

  embed_template(:component_title, ~S/
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    # <%= @component.name %>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  /)
end
