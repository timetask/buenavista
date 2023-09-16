defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Bundle
  alias BuenaVista.Helpers
  alias BuenaVista.Hydrator.Variable

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def sync_config(%Bundle{} = bundle) do
    modules = Helpers.find_component_modules(bundle.apps)
    sync_nomenclator(bundle, modules)
    sync_hydrator(bundle, modules)
  end

  def generate_css_files() do
    for %Bundle{css: %Bundle.Css{out_dir: out_dir}} = bundle when is_binary(out_dir) <-
          BuenaVista.Config.get_bundles() do
      module_paths = generate_modules_css_files(bundle)
      generate_root_css_file(bundle, module_paths)
    end
  end

  # ----------------------------------------
  # Nomenclator
  # ----------------------------------------
  defp sync_nomenclator(%Bundle{} = bundle, modules) do
    if match?(%Bundle.Nomenclator{}, bundle.nomenclator) do
      nomenclator = Helpers.get_nomenclator(bundle)

      assigns = [
        module_name: nomenclator,
        existing_class_names: nomenclator.get_class_names(),
        parent: bundle.nomenclator.parent,
        modules: modules
      ]

      maybe_create_dir(bundle.nomenclator.file)
      create_file(bundle.nomenclator.file, nomenclator_template(assigns), force: true)
      System.cmd("mix", ["format", bundle.nomenclator.file])
    end
  end

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

  defp class_name_def(component, variant, option, existing_class_names, parent) do
    if class_name = Map.get(existing_class_names, {component, variant, option}) do
      ~s|def class_name(:#{component}, :#{variant}, :#{option}), do: "#{class_name}"|
    else
      ~s|# def class_name(:#{component}, :#{variant}, :#{option}), do: "#{parent && parent.class_name(component, variant, option)}"|
    end
  end

  # ----------------------------------------
  # Hydrator
  # ----------------------------------------
  defp sync_hydrator(%Bundle{} = bundle, modules) do
    if match?(%Bundle.Hydrator{}, bundle.hydrator) do
      nomenclator = Helpers.get_nomenclator(bundle)
      parent = bundle.hydrator.parent
      hydrator = Helpers.get_hydrator(bundle)

      {variables, styles} =
        if function_exported?(hydrator, :__info__, 1) do
          {hydrator.get_variables(), hydrator.get_styles_map()}
        else
          {parent.get_variables() |> set_parent_true(), parent.get_styles_map() |> set_parent_true()}
        end

      grouped_variables =
        ordered_group_by(variables, fn {key, _var} ->
          [key | _rest] = key |> Atom.to_string() |> String.split("_")
          key
        end)

      assigns = [
        module_name: hydrator,
        nomenclator: nomenclator,
        imports: bundle.hydrator.imports,
        variables: grouped_variables,
        styles: styles,
        parent: parent,
        modules: modules
      ]

      maybe_create_dir(bundle.hydrator.file)
      create_file(bundle.hydrator.file, hydrator_template(assigns), force: true)
      System.cmd("mix", ["format", bundle.hydrator.file])
    end
  end

  defp set_parent_true(items) when is_list(items) do
    for {key, val} <- items, do: {key, %{val | parent: true}}
  end

  defp set_parent_true(items) when is_map(items) do
    for {key, val} <- items, into: %{}, do: {key, %{val | parent: true}}
  end

  defp ordered_group_by(items, group_fn) when is_list(items) and is_function(group_fn) do
    for item <- items, reduce: [] do
      acc ->
        key =
          case group_fn.(item) do
            key when is_atom(key) -> key
            key when is_binary(key) -> String.to_atom(key)
          end

        if Keyword.has_key?(acc, key) do
          children = Keyword.get(acc, key)
          Keyword.replace(acc, key, [item | children])
        else
          Keyword.put(acc, key, [item])
        end
    end
  end

  defp maybe_create_dir(file) do
    dir = Path.dirname(file)

    unless File.exists?(dir) do
      create_directory(dir, force: true)
    end
  end

  embed_template(:hydrator, ~S/
  defmodule <%= Helpers.pretty_module(@module_name) %> do
    use BuenaVista.Hydrator, 
      nomenclator: <%= Helpers.pretty_module(@nomenclator) %><%= unless is_nil(@parent) do %>, 
      parent: <%= Helpers.pretty_module(@parent) %><% end %>
   
    <%= for import <- @imports do %>
      import <%= Helpers.pretty_module(import) %><% end %>

    <%= for {group, variables} <- @variables do %>
    # <%= group %><%= for {_, variable} <- variables do %>
      <%= variable_def(variable) %><% end %>
    <% end %>

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
        <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          <%= style_def(@styles, component.name, :classes, class_key) %><% end %>
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            <%= style_def(@styles, component.name, variant.name, option) %><% end %>
        <% end %>
      <% end %>
    <% end %>
  end
  /)

  def variable_def(%Variable{} = variable) do
    case {variable.parent, variable.property} do
      {true, {:function, func_body}} -> ~s|# variable :#{variable.key}, ~FUNC[#{func_body}]|
      {false, {:function, func_body}} -> ~s|variable :#{variable.key}, ~FUNC[#{func_body}]|
      {true, :raw_value} -> ~s|# variable :#{variable.key}, "#{variable.css_value}"|
      {false, :raw_value} -> ~s|variable :#{variable.key}, "#{variable.css_value}"|
    end
  end

  defp style_def(styles, component, variant, option) do
    if style = Map.get(styles, {component, variant, option}) do
      if style.parent,
        do: ~s/# style [:#{component}, :#{variant}, :#{option}], ~CSS""" \n# #{style.css |> comment_lines()}"""/,
        else: ~s/style [:#{component}, :#{variant}, :#{option}], ~CSS"""\n #{style.css} """/
    else
      ~s/# style [:#{component}, :#{variant}, :#{option}], ~CSS"""\n# """/
    end
  end

  defp generate_modules_css_files(%Bundle{} = bundle) do
    nomenclator = Helpers.get_nomenclator(bundle)
    hydrator = Helpers.get_hydrator(bundle)

    variables = hydrator.get_variables()

    css_variables =
      for {_, variable} <- variables, into: %{} do
        {variable.key, "var(--#{variable.css_key})"}
      end

    for {module, components} <- BuenaVista.Helpers.find_component_modules(bundle.apps) do
      module_name = Helpers.last_module_alias(module)
      module_filename = "#{module_name}.css"
      module_path = Path.join([bundle.css.out_dir, bundle.name, module_filename])

      assigns = [
        nomenclator: nomenclator,
        hydrator: hydrator,
        variables: css_variables,
        components: components
      ]

      create_file(module_path, component_template(assigns), force: true)

      System.cmd("prettier", [module_path, "--write"])
      "#{bundle.name}/#{module_filename}"
    end
  end

  embed_template(:component, """
  <%= for {_, component} <- @components do %>

  /* Component: <%= component.name  %> */
  .<%= apply(@nomenclator, :class_name, [component.name, :classes, :base_class]) %> {
    <%= apply(@hydrator, :css, [component.name, :classes, :base_class, @variables]) %>

    <%= for {class_key, _} <- component.classes, class_key != :base_class do %>
      .<%= apply(@nomenclator, :class_name, [component.name, :classes, class_key]) %> {
        <%= apply(@hydrator, :css, [component.name, :classes, class_key, @variables]) %>
      }
    <% end %>

    <%= for variant <- component.variants do %>
      /* Variant: <%= variant.name %> */

      <%= for {option, _class} <- variant.options do %>
        <%= if class_name = apply(@nomenclator, :class_name, [component.name, variant.name, option]) do %>
          &.<%= class_name %> {
            <%= apply(@hydrator, :css, [component.name, variant.name, option, @variables]) %>
          } 
        <% end %>
      <% end %>
    <% end %>
  }
  <% end %>
  """)

  defp generate_root_css_file(%Bundle{} = bundle, module_paths) when is_list(module_paths) do
    nomenclator = Helpers.get_nomenclator(bundle)
    hydrator = Helpers.get_hydrator(bundle)
    variables = hydrator.get_variables()
    root_path = Path.join(bundle.css.out_dir, "#{bundle.name}.css")

    assigns = [
      nomenclator: nomenclator,
      hydrator: hydrator,
      module_paths: module_paths,
      variables: variables
    ]

    create_file(root_path, root_template(assigns), force: true)
    System.cmd("prettier", [root_path, "--write"])
  end

  embed_template(:root, """
  /* ***********************************************************
                                                
                   BuenaVista Component Library

      > Source Code: https://github.com/timetask/buenavista
      > Nomenclator: <%= inspect(@nomenclator) %>
      > Hydrator: <%= inspect(@hydrator) %>

  *********************************************************** */
  <%= for path <- @module_paths do %>@import "<%= path %>";
  <% end %>

  :root {
    <%= for {_, variable} <- @variables do %>--<%= variable.css_key %>: <%= variable.css_value %>;
    <% end %>
  }
  """)

  # ----------------------------------------
  # Helpers
  # ----------------------------------------
  defp comment_lines(content) do
    String.replace(content, "\n", "\n# ")
  end

  embed_template(:module_title, ~S/
    # ---------------------------------------------------------------------
    # <%= Helpers.pretty_module(@module) %>
    # ---------------------------------------------------------------------
  /)

  embed_template(:component_title, ~S/
    # <%= @component.name %>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  /)
end
