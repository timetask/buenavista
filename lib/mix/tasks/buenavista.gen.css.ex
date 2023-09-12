defmodule Mix.Tasks.Buenavista.Gen.Css do
  use Mix.Task
  require Logger

  import Mix.Generator
  import Macro, only: [underscore: 1]

  alias BuenaVista.Bundle

  @requirements ["app.config"]
  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(_opts) do
    generate_css_files()
  end

  def generate_css_files() do
    for %Bundle{css: %Bundle.Css{out_dir: out_dir}} = bundle when is_binary(out_dir) <-
          BuenaVista.Config.get_bundles() do
      module_paths =
        for {module, components} <- BuenaVista.Helpers.find_component_modules(bundle) do
          module_name =
            module.__info__(:module)
            |> Atom.to_string()
            |> String.split(".")
            |> List.last()
            |> underscore()

          module_filename = "#{module_name}.css"
          module_path = Path.join(out_dir, module_filename)

          assigns = [
            nomenclator: bundle.nomenclator.module,
            hydrator: bundle.hydrator.module,
            components: components
          ]

          create_file(module_path, component_template(assigns), force: true)

          System.cmd("prettier", [module_path, "--write"])
          "#{module_name}/#{module_filename}"
        end

      variables = bundle.hydrator.module.get_variables()

      root_path = Path.join(out_dir, "#{bundle.name}.css")

      assigns = [
        nomenclator: bundle.nomenclator.module,
        hydrator: bundle.hydrator.module,
        module_paths: module_paths,
        variables: variables
      ]

      create_file(root_path, root_template(assigns), force: true)
      System.cmd("prettier", [root_path, "--write"])
    end
  end

  # def generate_css_files(name, out_dir, nomenclator, hydrator) do
  #   name = if is_nil(name), do: "buenavista", else: name |> underscore()
  #   out_dir = if is_nil(out_dir), do: "lib/assets/css", else: out_dir

  #   nomenclator =
  #     if is_nil(nomenclator),
  #       do: Application.get_env(:buenavista, :nomenclator, BuenaVista.Nomenclator.Default),
  #       else: String.to_existing_atom("Elixir." <> nomenclator)

  #   hydrator =
  #     if is_nil(hydrator),
  #       do: Application.get_env(:buenavista, :hydrator, BuenaVista.Hydrators.Empty),
  #       else: String.to_existing_atom("Elixir." <> hydrator)

  #   modules_base_dir = Path.join(out_dir, name)

  #   unless File.dir?(out_dir), do: create_directory(out_dir)
  #   unless File.dir?(modules_base_dir), do: create_directory(modules_base_dir)

  #   module_paths =
  #     for {module, components} <- BuenaVista.Helpers.find_component_modules(modules_base_dir) do
  #       module_name =
  #         module.__info__(:module)
  #         |> Atom.to_string()
  #         |> String.split(".")
  #         |> List.last()
  #         |> underscore()

  #       module_filename = "#{module_name}.css"
  #       module_path = Path.join(modules_base_dir, module_filename)

  #       assigns = [
  #         nomenclator: nomenclator,
  #         hydrator: hydrator,
  #         components: components
  #       ]

  #       create_file(module_path, component_template(assigns), force: true)

  #       System.cmd("prettier", [module_path, "--write"])
  #       "#{name}/#{module_filename}"
  #     end

  #   variables = hydrator.variables() |> flatten_variables()

  #   root_path = Path.join(out_dir, "#{name}.css")

  #   assigns = [
  #     nomenclator: nomenclator,
  #     hydrator: hydrator,
  #     module_paths: module_paths,
  #     variables: variables
  #   ]

  #   create_file(root_path, root_template(assigns), force: true)
  #   System.cmd("prettier", [root_path, "--write"])
  # end

  # defp join_key(nil, key), do: key
  # defp join_key(parent_key, key), do: "#{parent_key}-#{key}"

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
    <%= for variable <- @variables do %><%= variable %>
    <% end %>
  }
  """)

  embed_template(:component, """
  <%= for {_, component} <- @components do %>

  /* Component: <%= component.name  %> */
  .<%= apply(@nomenclator, :class_name, [component.name, :classes, :base_class]) %> {
    
    <%= for {class_key, _} <- component.classes, class_key != :base_class do %>
      .<%= apply(@nomenclator, :class_name, [component.name, :classes, class_key]) %> {
        <%= apply(@hydrator, :css, [component.name, :classes, class_key]) %>
      }
    <% end %>

    <%= for variant <- component.variants do %>
      /* Variant: <%= variant.name %> */

      <%= for {option, _class} <- variant.options do %>
        <%= if class_name = apply(@nomenclator, :class_name, [component.name, variant.name, option]) do %>
          &.<%= class_name %> {
            <%= apply(@hydrator, :css, [component.name, variant.name, option]) %>
          } 
        <% end %>
      <% end %>
    <% end %>
  }
  <% end %>
  """)
end
