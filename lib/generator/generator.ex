defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Generator.Utils

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def init(_app_name, _out_dir, _style, _name) do
    # style = Keyword.get(bundle, :style)
    # component_apps = Keyword.get(bundle, :component_apps)

    # modules = BuenaVista.ComponentFinder.find_component_modules()

    # generate_nomenclator(modules, app_name, out_dir, style, name)

    # if Utils.uses_hydrator?(style) do
    #   generate_hydrator(modules, app_name, out_dir, style, name)
    # end
  end

  def sync(bundle) do
    template = Keyword.get(bundle, :template)
    component_apps = Keyword.get(bundle, :component_apps)

    modules = BuenaVista.ComponentFinder.find_component_modules(component_apps)

    sync_nomenclator(bundle, modules)

    if Utils.uses_hydrator?(template) do
      sync_hydrator(bundle, modules)
    end
  end

  # ----------------------------------------
  # Core Functions
  # ----------------------------------------
  def sync_nomenclator(bundle, modules) do
    module_name = Utils.module_name(bundle, :nomenclator)
    delegate = Utils.delegate_nomenclator(bundle)
    nomenclator_file = Utils.config_file_path(bundle, :nomenclator)

    assigns = [
      module_name: module_name,
      delegate: delegate,
      modules: modules
    ]

    create_file(nomenclator_file, nomenclator_template(assigns), force: true)
    System.cmd("mix", ["format", nomenclator_file])
  end

  defp sync_hydrator(bundle, modules) do
    module_name = Utils.module_name(bundle, :hydrator)
    delegate = Utils.delegate_hydrator(bundle)
    hydrator_file = Utils.config_file_path(bundle, :hydrator)

    assigns = [
      module_name: module_name,
      delegate: delegate,
      modules: modules
    ]

    create_file(hydrator_file, hydrator_template(assigns), force: true)
    System.cmd("mix", ["format", hydrator_file])
  end

  # ----------------------------------------
  # Templates
  # ----------------------------------------
  embed_template(:nomenclator, ~S/
  defmodule <%= inspect @module_name %> do
    @behaviour BuenaVista.Nomenclator
    <%= unless is_nil(@delegate) do %>@delegate <%= pretty_module(@delegate) %><% end %>

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
        <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          # def class_name(:<%= component.name %>, :classes, :<%= class_key %>), do: "<%= unless is_nil(@delegate) do %><%= @delegate.class_name(:"#{component.name}", :classes, :"#{class_key}") %>"<% end %><% end %>
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            # def class_name(:<%= component.name %>, :<%= variant.name %>, :<%= option %>), do: "<%= unless is_nil(@delegate) do %><%= @delegate.class_name(:"#{component.name}", :"#{variant.name}", :"#{option}") %>"<% end %><% end %>
      <% end %>
    <% end %>
  <% end %>
  <%= unless is_nil(@delegate) do %>defdelegate class_name(component, variant, option), to: @delegate<% end %>
  end
  /)

  embed_template(:hydrator, ~S/
  defmodule <%= inspect @module_name %> do
    @behaviour BuenaVista.Hydrator
    <%= unless is_nil(@delegate) do %>@delegate <%= pretty_module(@delegate) %><% end %>
    
    # defp variables(), do: [] 

    <%= for {module, components} <- @modules do %>
      <%= module_title_template(module: module) %>

      <%= for {_, component} <- components do %>
      <%= component_title_template(component: component) %>

        <%= for {class_key, _} <- component.classes do %>
          # def css(:<%= component.name %>, :classes, :<%= class_key %>), do: ~S||<% end %> 
        <%= for variant <- component.variants do %>
          <%= for {option, _} <- variant.options do %>
            # def css(:<%= component.name %>, :<%= variant.name %>, :<%= option %>), do: ~S||<% end %>
        <% end %>
      <% end %>
    <% end %>

    <%= unless is_nil(@delegate) do %>defdelegate css(component, variant, option), to: @delegate<% end %>
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
