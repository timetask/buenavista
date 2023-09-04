defmodule BuenaVista.Generator do
  require Logger
  import Mix.Generator

  alias BuenaVista.Generator.Utils

  # ----------------------------------------
  # Public API
  # ----------------------------------------
  def init(app_name, out_dir, style_name) do
    app_name = Utils.sanitize_app_name(app_name)
    modules = BuenaVista.ComponentFinder.find_component_modules()

    generate_nomenclator(modules, app_name, out_dir, style, name)

    if Utils.uses_hydrator?(style) do
      generate_hydrator(modules, app_name, out_dir, style, name)
    end
  end

  def sync(_app_name, _out_dir, _style, _name) do
  end

  # ----------------------------------------
  # Core Functions
  # ----------------------------------------
  def generate_nomenclator(modules, app_name, out_dir, style, name) do
    module_name = Utils.module_name(app_name, :nomenclator, style, name)
    parent = Utils.parent_nomenclator(app_name, style)
    nomenclator_file = Utils.file_path(app_name, :nomenclator, style, name, out_dir)

    assigns = [
      module_name: module_name,
      parent: parent,
      modules: modules
    ]

    create_file(nomenclator_file, nomenclator_template(assigns))
    System.cmd("mix", ["format", nomenclator_file])
  end

  defp generate_hydrator(modules, app_name, out_dir, style, name) do
    module_name = Utils.module_name(app_name, :hydrator, style, name)
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

  # ----------------------------------------
  # Templates
  # ----------------------------------------
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
