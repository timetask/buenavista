defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Generator.Utils

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def init(app_name, out_dir, style, name) do
    # style = Keyword.get(bundle, :style)
    # component_apps = Keyword.get(bundle, :component_apps)

    # modules = BuenaVista.ComponentFinder.find_component_modules()

    # generate_nomenclator(modules, app_name, out_dir, style, name)

    # if Utils.uses_hydrator?(style) do
    #   generate_hydrator(modules, app_name, out_dir, style, name)
    # end
  end

  def sync(bundle) do
    style = Keyword.get(bundle, :style)
    component_apps = Keyword.get(bundle, :component_apps)

    modules = BuenaVista.ComponentFinder.find_component_modules(component_apps)

    sync_nomenclator(bundle, modules)

    if Utils.uses_hydrator?(style) do
      sync_hydrator(bundle, modules)
    end
  end

  # ----------------------------------------
  # Core Functions
  # ----------------------------------------
  def sync_nomenclator(bundle, modules) do
    module_name = Utils.module_name(bundle, :nomenclator)
    parent = Utils.parent_nomenclator(bundle)
    nomenclator_file = Utils.config_file_path(bundle, :nomenclator)

    assigns = [
      module_name: module_name,
      parent: parent,
      modules: modules
    ]

    create_file(nomenclator_file, nomenclator_template(assigns))
    System.cmd("mix", ["format", nomenclator_file])
  end

  defp sync_hydrator(bundle, modules) do
    module_name = Utils.module_name(bundle, :hydrator)
    parent = Utils.parent_hydrator(bundle)
    hydrator_file = Utils.config_file_path(bundle, :hydrator)

    assigns = [
      module_name: module_name,
      parent: parent,
      modules: modules
    ]

    create_file(hydrator_file, hydrator_template(assigns))
    System.cmd("mix", ["format", hydrator_file])
  end

  # ----------------------------------------
  # Templates
  # ----------------------------------------
  embed_template(:nomenclator, ~S/
  defmodule <%= inspect @module_name %> do
    use BuenaVista.Nomenclator

    <%= unless is_nil(@parent) do %>@parent <%= pretty_module(@parent) %><% end %>

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

    <%= unless is_nil(@parent) do %>@parent <%= pretty_module(@parent) %><% end %>
    
    # defp variables(), do: [] 

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
      <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          """ 
          def css(:<%= component.name %>, :classes, :<%= class_key %>), do: ~S|
            <%= unless is_nil(@parent) do %>
              <%= @parent.hydrate_css(:"#{component.name}", :classes, :"#{class_key}") %>
            <%end %>
          | 
          """<% end %> 
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            """ 
            def css(:<%= component.name %>, :<%= variant.name %>, :<%= option %>), do: ~S|
              <%= unless is_nil(@parent) do %>
                <%= @parent.hydrate_css(:"#{component.name}", :"#{variant.name}", :"#{option}") %>
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
    # <%= pretty_module(@module) %>
    # ----------------------------------------
  /)

  embed_template(:component_title, ~S/
    # - - - - - - - - - - - - - - - - - - - - 
    # <%= @component.name %>
    # - - - - - - - - - - - - - - - - - - - - 
  /)

  defp pretty_module(module) do
    module |> Atom.to_string() |> String.replace("Elixir.", "")
  end
end
