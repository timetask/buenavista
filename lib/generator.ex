defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Helpers
  alias BuenaVista.Hydrator.Variable
  alias BuenaVista.Theme

  @component_apps Application.compile_env(:buenavista, :apps, [:buenavista])

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def sync_config(themes) when is_list(themes) do
    for %BuenaVista.Theme{} = theme <- themes, reduce: %{} do
      cache ->
        {modules, cache} =
          case Map.get(cache, @component_apps) do
            nil ->
              modules = BuenaVista.Helpers.find_component_modules(@component_apps)
              {modules, Map.put(cache, @component_apps, modules)}

            modules ->
              {modules, cache}
          end

        sync_nomenclator(theme, modules)
        hydrator_path = sync_hydrator(theme, modules)

        unless is_nil(hydrator_path) do
          Code.compile_file(hydrator_path)
        end

        cache
    end
  end

  def generate_css_files(themes) do
    %{out_dirs: out_dirs} =
      for %Theme{css: %Theme.Css{out_dir: out_dir}} = theme when is_binary(out_dir) <- themes,
          reduce: %{cache: %{}, out_dirs: %{}} do
        %{cache: cache, out_dirs: out_dirs} ->
          {modules, cache} =
            case Map.get(cache, @component_apps) do
              nil ->
                modules = BuenaVista.Helpers.find_component_modules(@component_apps)
                {modules, Map.put(cache, @component_apps, modules)}

              modules ->
                {modules, cache}
            end

          module_paths = generate_modules_css_files(theme, modules)
          generate_root_css_file(theme, module_paths)

          %{cache: cache, out_dirs: Map.put(out_dirs, out_dir, true)}
      end

    for {out_dir, true} <- out_dirs do
      System.cmd("prettier", [out_dir, "--write"])
    end
  end

  # ----------------------------------------
  # Nomenclator
  # ----------------------------------------
  defp sync_nomenclator(%Theme{} = theme, modules) do
    if match?(%Theme.Nomenclator{}, theme.nomenclator) do
      nomenclator = Helpers.get_nomenclator(theme)

      assigns = [
        module_name: nomenclator,
        existing_class_names: nomenclator.get_class_names(),
        parent: theme.nomenclator.parent,
        modules: modules
      ]

      maybe_create_dir(theme.nomenclator.file)
      create_file(theme.nomenclator.file, nomenclator_template(assigns), force: true)
    end
  end

  embed_template(:nomenclator, ~S/
  defmodule <%= Helpers.pretty_module(@module_name) %> do
    use BuenaVista.Nomenclator,<%= unless is_nil(@parent) do %>parent: <%= Helpers.pretty_module(@parent) %><% end %>

    <%= for {module, components} <- @modules do %>
      <%= for {_, component} <- components do %>
        <%= comment_title_template(title: justify_between(Atom.to_string(component.name), Helpers.pretty_module(module), 68)) %>

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
  defp sync_hydrator(%Theme{} = theme, modules) do
    if match?(%Theme.Hydrator{}, theme.hydrator) do
      nomenclator = Helpers.get_nomenclator(theme)
      parent = theme.hydrator.parent
      hydrator = Helpers.get_hydrator(theme)

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
        imports: theme.hydrator.imports,
        variables: grouped_variables,
        styles: styles,
        parent: parent,
        modules: modules
      ]

      maybe_create_dir(theme.hydrator.file)
      create_file(theme.hydrator.file, hydrator_template(assigns), force: true)
      theme.hydrator.file
    else
      nil
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

    <%= comment_title_template(title: "Variables") %>
    
    <%= for {group, variables} <- @variables do %>
    # <%= group %><%= for {_, variable} <- variables do %>
    <%= variable_def(variable) %><% end %>
    <% end %>

    <%= for {module, components} <- @modules do %>
    <%= for {_, component} <- components do %>
    <%= comment_title_template(title: justify_between(Helpers.pretty_module(module), Atom.to_string(component.name), 68)) %>

    <%= for {class_key, _} <- component.classes do %>
    <%= if apply(@nomenclator, :class_name, [component.name, :classes, class_key]) do %><%= style_def(@styles, component.name, :classes, class_key) %><% end %><% end %>
    <%= for variant <- component.variants do %>
    <%= for {option, _} <- variant.options do %>
    <%= if apply(@nomenclator, :class_name, [component.name, variant.name, option]) do %><%= style_def(@styles, component.name, variant.name, option) %><% end %><% end %>
    <% end %>
    <% end %>
    <% end %>
  end
  /)

  def variable_def(%Variable{} = variable) do
    case {variable.parent, variable.property} do
      {true, {:function, func_body}} -> ~s|# var :#{variable.key}, ~VAR[#{func_body}]|
      {false, {:function, func_body}} -> ~s|var :#{variable.key}, ~VAR[#{func_body}]|
      {true, :raw_value} -> ~s|# var :#{variable.key}, "#{variable.css_value}"|
      {false, :raw_value} -> ~s|var :#{variable.key}, "#{variable.css_value}"|
    end
  end

  defp style_def(styles, component, variant, option) do
    if style = Map.get(styles, {component, variant, option}) do
      if style.parent,
        do: ~s/# style [:#{component}, :#{variant}, :#{option}], ~CSS""" \n# #{style.css |> comment_lines()}  """/,
        else: ~s/style [:#{component}, :#{variant}, :#{option}], ~CSS"""\n #{style.css}    """/
    else
      ~s/# style [:#{component}, :#{variant}, :#{option}], ~CSS"""\n# """/
    end
  end

  defp generate_modules_css_files(%Theme{} = theme, modules) do
    nomenclator = Helpers.get_nomenclator(theme)
    hydrator = Helpers.get_hydrator(theme)

    variables =
      for {_, variable} <- hydrator.get_variables(), into: %{} do
        {variable.key, "var(--#{variable.css_key})"}
      end

    for {module, components} <- modules do
      module_name = Helpers.last_module_alias(module)
      module_filename = "#{module_name}.css"
      module_path = Path.join([theme.css.out_dir, theme.name, module_filename])

      assigns = [
        nomenclator: nomenclator,
        hydrator: hydrator,
        variables: variables,
        components: components
      ]

      create_file(module_path, component_template(assigns), force: true)

      "#{theme.name}/#{module_filename}"
    end
  end

  embed_template(:component, """
  <%= for {_, component} <- @components do %>

  /* Component: <%= component.name  %> */
  .<%= apply(@nomenclator, :class_name, [component.name, :classes, :base_class]) %> {
    <%= apply(@hydrator, :css, [component.name, :classes, :base_class, @variables]) %>

    <%= for {class_key, _} <- component.classes, class_key != :base_class do %>
      <%= if class_name = apply(@nomenclator, :class_name, [component.name, :classes, class_key]) do %>
      <%= if css = apply(@hydrator, :css, [component.name, :classes, class_key, @variables]) do %>
      .<%= class_name %>{
        <%= css %>
      }<% end %><% end %>
    <% end %>

    <%= for variant <- component.variants do %>
      /* Variant: <%= variant.name %> */

      <%= for {option, _class} <- variant.options do %>
        <%= if class_name = apply(@nomenclator, :class_name, [component.name, variant.name, option]) do %>
        <%= if css = apply(@hydrator, :css, [component.name, variant.name, option, @variables]) do %>
          &.<%= class_name %> {
            <%= css  %>
          }<% end %>
        <% end %>
      <% end %>
    <% end %>
  }
  <% end %>
  """)

  defp generate_root_css_file(%Theme{} = theme, module_paths) when is_list(module_paths) do
    nomenclator = Helpers.get_nomenclator(theme)
    hydrator = Helpers.get_hydrator(theme)
    variables = hydrator.get_variables()
    root_path = Path.join(theme.css.out_dir, "#{theme.name}.css")

    assigns = [
      nomenclator: nomenclator,
      hydrator: hydrator,
      module_paths: module_paths,
      variables: variables
    ]

    create_file(root_path, root_template(assigns), force: true)
  end

  embed_template(:root, """
  /* ***********************************************************
                                                
                   BuenaVista Component Library

      > Source Code: https://github.com/timetask/buenavista
      > Nomenclator: <%= Helpers.pretty_module(@nomenclator) %>
      > Hydrator: <%= Helpers.pretty_module(@hydrator) %>

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

  embed_template(:comment_title, ~S/
    # ---------------------------------------------------------------------
    # <%= @title %>
    # ---------------------------------------------------------------------
  /)

  defp justify_between(s1, s2, total) when is_binary(s1) and is_binary(s2) and is_integer(total) do
    s1_len = String.length(s1)
    s2_len = String.length(s2)
    spaces = max(total - s1_len - s2_len, 1)

    s1 <> String.duplicate(" ", spaces) <> s2
  end
end
