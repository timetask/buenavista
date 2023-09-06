defmodule Mix.Tasks.Buenavista.Gen.Css do
  use Mix.Task
  require Logger

  import Mix.Generator

  alias BuenaVista.Finder
  import Macro, only: [underscore: 1]

  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(opts) do
    Mix.Task.run("app.config")

    {parsed, _args, _errors} =
      OptionParser.parse(opts,
        aliasses: [n: :name, o: :out, h: :help],
        strict: [name: :string, out: :string, nomenclator: :string, hydrator: :string, help: :boolean]
      )

    help = Keyword.get(parsed, :help)
    name = Keyword.get(parsed, :name)
    nomenclator = Keyword.get(parsed, :nomenclator)
    hydrator = Keyword.get(parsed, :hydrator)
    out_dir = Keyword.get(parsed, :out)

    if help do
      """
      Generates CSS files for all your BuenaVista components. You can add your
      own ones, by adding to your component modules `use BuenaVista.Component`,
      and then adding either `variant` and/or `classes` macro before the
      target component definitions.

      To change the names of the CSS classes, you can either pass it to this command
      with --nomenclator, or you can set it in your app configuration:

          config :buenavista, nomenclator: MyNomenclator

      To change the css content of your classes, you can either pass it to this command
      with --hydartor, or you can set it in your app configuration:

          config :buenavista, hydrator: MyHydrator

      Usage: 

          mix buenavista.gen.css [options] 

      Examples:

          $ mix buenavista.gen.css 
          $ mix buenavista.gen.css --name dark_theme -out assets/css
          $ mix buenavista.gen.css --hydrator MyApp.MyHydrator
          $ mix buenavista.gen.css --nomenclator MyApp.MyNomenclator

      Options:

      -n, --name                 Name used to generate CSS files. Default: buenavista
      -o, --out                  Output directory. Default: lib/assets/css
      --nomenclator             Module to be used for class names generation
      --hydrator                 Module to be used for css hydration
      -h, --help                 Show this help

      """
    else
      generate_css_files(name, out_dir, nomenclator, hydrator)
    end
  end

  def generate_css_files(name, out_dir, nomenclator, hydrator) do
    name = if is_nil(name), do: "buenavista", else: name |> underscore()
    out_dir = if is_nil(out_dir), do: "lib/assets/css", else: out_dir

    nomenclator =
      if is_nil(nomenclator),
        do: Application.get_env(:buenavista, :nomenclator, BuenaVista.Nomenclator.Default),
        else: String.to_existing_atom("Elixir." <> nomenclator)

    hydrator =
      if is_nil(hydrator),
        do: Application.get_env(:buenavista, :hydrator, BuenaVista.Hydrators.Empty),
        else: String.to_existing_atom("Elixir." <> hydrator)

    modules_base_dir = Path.join(out_dir, name)

    unless File.dir?(out_dir), do: create_directory(out_dir)
    unless File.dir?(modules_base_dir), do: create_directory(modules_base_dir)

    module_paths =
      for {module, components} <- Finder.find_component_modules(modules_base_dir) do
        module_name =
          module.__info__(:module)
          |> Atom.to_string()
          |> String.split(".")
          |> List.last()
          |> underscore()

        module_filename = "#{module_name}.css"
        module_path = Path.join(modules_base_dir, module_filename)

        assigns = [
          nomenclator: nomenclator,
          hydrator: hydrator,
          components: components
        ]

        create_file(module_path, component_template(assigns), force: true)

        System.cmd("prettier", [module_path, "--write"])
        "#{name}/#{module_filename}"
      end

    variables = hydrator.variables() |> flatten_variables()

    root_path = Path.join(out_dir, "#{name}.css")

    assigns = [
      nomenclator: nomenclator,
      hydrator: hydrator,
      module_paths: module_paths,
      variables: variables
    ]

    create_file(root_path, root_template(assigns), force: true)
    System.cmd("prettier", [root_path, "--write"])
  end

  defp flatten_variables(variables, parent_key \\ nil) do
    for {key, value} <- variables do
      if is_list(value) do
        flatten_variables(value, join_key(parent_key, key))
      else
        "--#{join_key(parent_key, key)}: #{value};"
      end
    end
  end

  defp join_key(nil, key), do: key
  defp join_key(parent_key, key), do: "#{parent_key}-#{key}"

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
