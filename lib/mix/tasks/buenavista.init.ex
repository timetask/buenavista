defmodule Mix.Tasks.Buenavista.Init do
  use Mix.Task
  require Logger

  import Mix.Generator

  alias Mix.Tasks.Buenavista.Utils

  @moduledoc """
  Generates both Nomenclator and Hydrator modules to be used to configure
  both BuenaVista and your own components. 

  Usage: 

      mix buenavista.init [options] 

  Examples:

      $ mix buenavista.init --style tailwind_classes --out apps/my_app/lib/components/config
      $ mix buenavista.init -n components -s vanilla -o lib/my_app_web/buenavista

  Options:

  -s, --style                Framework & style to be used.
                             Options:
                             - tailwind_inline
                             - tailwind_classes
                             - bootstrap
                             - bulma
                             - foundation
                             - vanilla
                             Default: vanilla
  -o, --out                  Output directory. Use relative path from project root.
                             Default lib/<your_app>_web/components/config
  -h, --help                 Show this help
  """

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    Mix.Task.run("app.config")

    {parsed, _args, _errors} =
      OptionParser.parse(opts,
        aliasses: [n: :name, s: :style, o: :out, h: :help],
        strict: [name: :string, style: :string, out: :string, help: :boolean]
      )

    style = Keyword.get(parsed, :style, "vanilla") |> String.to_existing_atom()
    out_dir = Keyword.get(parsed, :out)
    help = Keyword.get(parsed, :help)

    if help do
      IO.puts(@moduledoc)
    else
      {:ok, app_name} = :application.get_application(__MODULE__)
      app_name = Utils.sanitize_app_name(app_name)
      modules = BuenaVista.ComponentFinder.find_component_modules()

      generate_nomenclator(modules, app_name, out_dir, style)

      if Utils.uses_hydrator?(style) do
        generate_hydrator(modules, app_name, out_dir, style)
      end
    end
  end

  defp generate_nomenclator(modules, app_name, out_dir, style) do
    module_name = Utils.module_name(app_name, :nomenclator, style)
    parent = Utils.parent_nomenclator(app_name, style)
    nomenclator_file = Utils.file_path(app_name, :nomenclator, style, out_dir)

    assigns = [
      module_name: module_name,
      parent: parent,
      modules: modules
    ]

    create_file(nomenclator_file, nomenclator_template(assigns))
    System.cmd("mix", ["format", nomenclator_file])
  end

  defp generate_hydrator(modules, app_name, out_dir, style) do
    module_name = Utils.module_name(app_name, :hydrator, style)
    parent = Utils.parent_hydrator(app_name, style)
    hydrator_file = Utils.file_path(app_name, :hydrator, style, out_dir)

    assigns = [
      module_name: module_name,
      parent: parent,
      modules: modules
    ]

    create_file(hydrator_file, hydrator_template(assigns))
    System.cmd("mix", ["format", hydrator_file])
  end

  embed_template(:nomenclator, ~S/
  defmodule <%= inspect @module_name %> do
    use BuenaVista.Nomenclator

    <%= unless is_nil(@parent) do %>@parent <%= @parent %><% end %>

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
      <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          # defp class_name(:<%= component.name %>, :classes, :<%= class_key %>), do: "<%= unless is_nil(@parent) do %><%= @parent.get_class_name(:"#{component.name}", :classes, :"#{class_key}") %>"<% end %><% end %>
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            # defp class_name(:<%= component.name %>, :<%= variant.name %>, :<%= option %>), do: "<%= unless is_nil(@parent) do %><%= @parent.get_class_name(:"#{component.name}", :"#{variant.name}", :"#{option}") %>"<% end %><% end %>
        <% end %>
      <% end %>
  <% end %>
  end
  /)

  embed_template(:hydrator, ~S/
  defmodule <%= inspect @module_name %> do
    use BuenaVista.Hydrator

    <%= unless is_nil(@parent) do %>@parent <%= @parent %><% end %>
    
    # defp variables(), do: [] 

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
      <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          """ 
          defp css(:<%= component.name %>, :classes, :<%= class_key %>), do: ~S|
            <%= unless is_nil(@parent) do %>
              <%= @parent.css(:"#{component.name}", :classes, :"#{class_key}") %>
            <%end %>
          | 
          """<% end %> 
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            """ 
            defp css(:<%= component.name %>, :<%= variant.name %>, :<%= option %>), do: ~S|
              <%= unless is_nil(@parent) do %>
                <%= @parent.get_css(:"#{component.name}", :"#{variant.name}", :"#{option}") %>
              <%end %>
            | 
            """<% end %>
        <% end %>
      <% end %>
    <% end %>
  end
  /)

  embed_template(:module_title, ~S/
    # ----------------------------------------
    # <%= @module |> Atom.to_string() |> String.replace("Elixir.", "") %>
    # ----------------------------------------
  /)

  embed_template(:component_title, ~S/
    # - - - - - - - - - - - - - - - - - - - - 
    # <%= @component.name %>
    # - - - - - - - - - - - - - - - - - - - - 
  /)
end
