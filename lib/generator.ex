defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Component
  alias BuenaVista.Helpers
  alias BuenaVista.Hydrator.Variable
  alias BuenaVista.Theme

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def generate_theme_files(themes) when is_list(themes) do
    for %Theme{} = theme <- themes,
        %Theme.App{} = app <- theme.apps,
        reduce: %{} do
      modules_cache ->
        {modules, modules_cache} = Helpers.get_component_modules_from_cache(app, modules_cache)

        sync_nomenclator(theme, app, modules)
        hydrator_path = sync_hydrator(theme, app, modules)

        unless is_nil(hydrator_path) do
          Code.put_compiler_option(:ignore_module_conflict, true)
          Code.compile_file(hydrator_path)
        end

        modules_cache
    end
  end

  def generate_css_files(themes) do
    for %Theme{gen_css?: true} = theme <- themes, reduce: %{} do
      modules_cache ->
        {modules_cache, all_raw_css} =
          for %Theme.App{} = app <- theme.apps, reduce: {modules_cache, []} do
            {modules_cache, all_raw_css} ->
              {modules, modules_cache} = Helpers.get_component_modules_from_cache(app, modules_cache)

              raw_css =
                for {_module, components} <- modules, into: "" do
                  generate_app_components_raw_css(app, components)
                end

              {modules_cache, [{app, raw_css} | all_raw_css]}
          end

        generate_theme_css_file(theme, all_raw_css)

        modules_cache
    end
  end

  # ----------------------------------------
  # Nomenclator
  # ----------------------------------------
  defp sync_nomenclator(%Theme{} = theme, %Theme.App{} = app, modules) do
    if theme.extend == :nomenclator do
      assigns = [
        app: app,
        existing_class_names: app.nomenclator.get_class_names(),
        modules: modules
      ]

      Helpers.write_and_format_module(app.nomenclator.file, nomenclator_template(assigns))
    end
  end

  embed_template(:nomenclator, ~S/
  defmodule <%= Helpers.pretty_module(@app.nomenclator.module) %> do
    use BuenaVista.Nomenclator,<%= unless is_nil(@app.nomenclator.parent_module) do %>parent: <%= Helpers.pretty_module(@app.nomenclator.parent_module) %><% end %>

    <%= for {module, components} <- @modules do %>
      <%= for {_, component} <- components do %>
        <%= comment_title_template(title: justify_between(Atom.to_string(component.name), Helpers.pretty_module(module), 68)) %>

        <%= for {class_key, _} <- component.classes do %>
          <%= class_name_def(component.name, :classes, class_key, @existing_class_names, @app.nomenclator.parent_module) %><% end %>
        <%= for variant <- component.variants do %>
          <%= for {_, option} <- variant.options do %>
            <%= class_name_def(component.name, variant.name, option.name, @existing_class_names, @app.nomenclator.parent_module) %><% end %>
      <% end %>
    <% end %>
  <% end %>
  <%= unless is_nil(@app.nomenclator.parent_module) do %>defdelegate class_name(component, variant, option), to: @app.nomenclator.parent_module<% end %>
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
  defp sync_hydrator(%Theme{} = theme, %Theme.App{} = app, modules) do
    if theme.extend == :hydrator do
      {variables, styles} = get_variables_and_styles(app)
      variables = group_variables_by_name(variables)

      assigns = [
        app: app,
        variables: variables,
        styles: styles,
        modules: modules
      ]

      Helpers.write_and_format_module(app.hydrator.file, hydrator_template(assigns))
      app.hydrator.file
    else
      nil
    end
  end

  defp get_variables_and_styles(%Theme.App{} = app) do
    if function_exported?(app.hydrator.module, :__info__, 1) do
      {app.hydrator.module.get_variables(), app.hydrator.module.get_styles_map()}
    else
      if is_nil(app.hydrator.parent_module) do
        {[], %{}}
      else
        {app.hydrator.parent_module.get_variables() |> set_parent_true(),
         app.hydrator.parent_module.get_styles_map() |> set_parent_true()}
      end
    end
  end

  defp group_variables_by_name(variables) do
    ordered_group_by(variables, fn {key, _var} ->
      key |> Atom.to_string() |> String.split("_") |> List.first()
    end)
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

  defp set_parent_true(items) when is_list(items) do
    for {key, val} <- items, do: {key, %{val | parent: true}}
  end

  defp set_parent_true(items) when is_map(items) do
    for {key, val} <- items, into: %{}, do: {key, %{val | parent: true}}
  end

  embed_template(:hydrator, ~S/
  defmodule <%= Helpers.pretty_module(@app.hydrator.module) %> do
    use BuenaVista.Hydrator, 
      nomenclator: <%= Helpers.pretty_module(@app.nomenclator.module) %>,
      parent: <%= Helpers.pretty_module(@app.hydrator.parent_module) %>
   
    <%= for import <- @app.hydrator.imports do %>
      import <%= Helpers.pretty_module(import) %><% end %>

    <%= comment_title_template(title: "Variables") %>
    
    <%= for {group, variables} <- @variables do %>
    # <%= group %><%= for {_, variable} <- variables do %>
    <%= variable_def(variable) %><% end %>
    <% end %>

    <%= for {module, components} <- @modules do %>
    <%= for {_, component} <- components do %>
    <%= comment_title_template(title: justify_between(Helpers.pretty_module(module), Atom.to_string(component.name), 68)) %>

    <%= for class <- component.classes do %>
    <%= if apply(@app.nomenclator.module, :class_name, [component.name, :classes, class.name]) do %><%= style_def(@styles, component.name, class.name) %><% end %><% end %>
    <%= for variant <- component.variants do %>
    <%= for option <- variant.options do %>
    <%= if apply(@app.nomenclator.module, :class_name, [component.name, variant.name, option.name]) do %><%= style_def(@styles, component.name, variant.name, option.name) %><% end %><% end %>
    <% end %>
    <% end %>
    <% end %>
  end
  /)

  def variable_def(%Variable{} = variable) do
    case {variable.parent, variable.property} do
      {true, %{type: :var, raw_body: raw_body}} -> ~s|# var :#{variable.key}, ~VAR[#{raw_body}]|
      {false, %{type: :var, raw_body: raw_body}} -> ~s|var :#{variable.key}, ~VAR[#{raw_body}]|
      {true, %{type: :raw_value}} -> ~s|# var :#{variable.key}, "#{variable.css_value}"|
      {false, %{type: :raw_value}} -> ~s|var :#{variable.key}, "#{variable.css_value}"|
    end
  end

  defp style_def(styles, component, class_key) do
    if style = Map.get(styles, {component, :classes, class_key}) do
      if style.parent,
        do: ~s/# style :#{component}, :#{class_key}, ~CSS""" \n# #{style.raw_css |> comment_lines()}  """/,
        else: ~s/style :#{component}, :#{class_key}, ~CSS"""\n #{style.raw_css}    """/
    else
      ~s/# style :#{component}, :#{class_key}, ~CSS"""\n# """/
    end
  end

  defp style_def(styles, component, variant, option) do
    if style = Map.get(styles, {component, variant, option}) do
      if style.parent,
        do: ~s/# style :#{component}, :#{variant}, :#{option}, ~CSS""" \n# #{style.raw_css |> comment_lines()}  """/,
        else: ~s/style :#{component}, :#{variant}, :#{option}, ~CSS"""\n #{style.raw_css}    """/
    else
      ~s/# style :#{component}, :#{variant}, :#{option}, ~CSS"""\n# """/
    end
  end

  # ----------------------------------------
  # CSS
  # ----------------------------------------
  def generate_app_components_raw_css(%Theme.App{} = app, components, prefix \\ nil) do
    variables =
      for {_, variable} <- app.hydrator.module.get_variables(), into: %{} do
        {variable.key, variable.css_value}
      end

    rules =
      for {_, component} <- Enum.reverse(components), reduce: [] do
        rules ->
          %Component.Class{} = base_class = Enum.find(component.classes, &(&1.name == :base_class))

          css = app.hydrator.module.css(component.name, :classes, :base_class, variables)
          css_tokens = css |> BuenaVista.CssTokenizer.build_tokens() |> BuenaVista.CssTokenizer.sort_tokens()
          scope = [{:scope, base_class.class_name}, {:scope, prefix}]
          rules = build_rules(scope, css_tokens, [], rules)

          rules =
            for %Component.Class{} = class <- component.classes, class.name != :base_class, reduce: rules do
              rules ->
                css = app.hydrator.module.css(component.name, :classes, class.name, variables)
                css_tokens = css |> BuenaVista.CssTokenizer.build_tokens() |> BuenaVista.CssTokenizer.sort_tokens()
                scope = [{:scope, class.class_name}, {:scope, base_class.class_name}, {:scope, prefix}]
                build_rules(scope, css_tokens, [], rules)
            end

          for %Component.Variant{} = variant <- component.variants,
              %Component.Option{} = option <- variant.options,
              reduce: rules do
            rules ->
              css = app.hydrator.module.css(component.name, variant.name, option.name, variables)
              css_tokens = css |> BuenaVista.CssTokenizer.build_tokens() |> BuenaVista.CssTokenizer.sort_tokens()
              scope = [{:modifier, option.class_name}, {:scope, base_class.class_name}, {:scope, prefix}]
              build_rules(scope, css_tokens, [], rules)
          end
      end

    rules
    |> rules_to_iodata()
    |> IO.iodata_to_binary()
  end

  defp build_rules(scope, [%BuenaVista.CssTokenizer.Property{} = prop | rest], properties, rules) do
    build_rules(scope, rest, [prop | properties], rules)
  end

  defp build_rules(scope, [%BuenaVista.CssTokenizer.Scope{} = nested_scope | rest], properties, rules) do
    new_rule = [{:properties, properties} | scope]
    child_rules = build_rules([{:internal_scope, nested_scope.selector} | scope], nested_scope.tokens, [], [new_rule])

    sibling_rules =
      if Enum.empty?(rest),
        do: [],
        else: build_rules(scope, rest, [], [])

    sibling_rules ++ child_rules ++ rules
  end

  defp build_rules(scope, [], properties, rules) do
    new_rule = [{:properties, properties} | scope]
    [new_rule | rules]
  end

  defp rules_to_iodata(rules) when is_list(rules) do
    for rule <- rules, reduce: [] do
      segments ->
        rule =
          rule
          |> Enum.reverse()
          |> Enum.reduce_while([], fn segment, acc ->
            case segment do
              {:internal_scope, selector} ->
                cond do
                  String.starts_with?(selector, "&") ->
                    {:cont, [{:internal_modifier, String.replace(selector, "&", "")} | acc]}

                  String.ends_with?(selector, "&") ->
                    replace_string = [acc] |> rules_to_iodata() |> IO.iodata_to_binary()
                    selector = String.replace(selector, "&", replace_string)
                    {:cont, [{:internal_modifier, selector}]}

                  true ->
                    {:cont, [{:internal_scope, selector} | acc]}
                end

              _ ->
                {:cont, [segment | acc]}
            end
          end)

        for segment <- rule, reduce: segments do
          segments ->
            rule_segment_to_iodata(segment, segments)
        end
    end
  end

  defp rule_segment_to_iodata({:modifier, nil}, acc), do: acc

  defp rule_segment_to_iodata({:modifier, selector}, acc) do
    [".#{selector}" | acc]
  end

  defp rule_segment_to_iodata({:internal_modifier, selector}, acc) do
    [selector | acc]
  end

  defp rule_segment_to_iodata({:internal_scope, selector}, acc) do
    [" #{selector}" | acc]
  end

  defp rule_segment_to_iodata({:scope, nil}, acc), do: acc

  defp rule_segment_to_iodata({:scope, selector}, acc) do
    [" .#{selector}" | acc]
  end

  defp rule_segment_to_iodata({:properties, properties}, acc) do
    acc = ["}\n" | acc]

    acc =
      for prop <- properties, reduce: acc do
        acc ->
          ["  #{prop.attr}: #{prop.value};\n" | acc]
      end

    [" {\n" | acc]
  end

  defp generate_theme_css_file(%Theme{} = theme, all_raw_css) when is_list(all_raw_css) do
    root_path = Path.join(theme.css_dir, "#{theme.name}.css")

    assigns = [
      theme: theme,
      all_raw_css: all_raw_css
    ]

    create_file(root_path, root_template(assigns), force: true)
  end

  embed_template(:root, """
  /* ***********************************************************
                                                
                   BuenaVista Component Library

      > Source Code: https://github.com/timetask/buenavista
      > Theme: <%= @theme.name %>
      > Apps: <%= @theme.apps |> Enum.map(& &1.name) |>  Enum.join(", ") %>

  *********************************************************** */
  <%= for {app, raw_css} <- @all_raw_css do %>
    /* 
      Application: :<%= app.name %>
      Nomenclator: <%= Helpers.pretty_module(app.nomenclator.module) %>
      Hydrator:    <%= Helpers.pretty_module(app.hydrator.module) %> 
    */
    <%= raw_css %>
  <% end %>
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
