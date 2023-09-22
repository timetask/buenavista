defmodule BuenaVista.Gallery.GalleryLive do
  use Phoenix.LiveView,
    layout: {Timetask.LayoutsHTML, :base}

  import BuenaVista

  alias BuenaVista.Component
  alias BuenaVista.Gallery.URL
  alias BuenaVista.Helpers
  alias BuenaVista.Theme

  @config Application.compile_env(:buenavista, :gallery)

  @impl true
  def mount(params, _session, socket) do
    theme = get_current_theme(params)
    modules = Helpers.find_component_modules(theme.apps)

    {:ok,
     socket
     |> assign(:page_title, "Gallery")
     |> assign(:modules, modules)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, handle_action(socket.assigns.live_action, params, socket)}
  end

  def handle_action(:index, _params, socket) do
    assign(socket, :current_component, nil)
  end

  def handle_action(:component, %{"component" => component}, socket) do
    component_name = String.to_existing_atom(component)

    component_search =
      for {_module, components} <- socket.assigns.modules, reduce: nil do
        acc -> find_component(components, component_name, acc)
      end

    case component_search do
      %Component{} = component -> assign(socket, :current_component, component)
      _ -> push_patch(socket, to: URL.index())
    end
  end

  @impl true
  def render(assigns) do
    assigns =
      assign_new(assigns, :title, fn -> Keyword.get(@config, :sidebar_title, "BuenaVista Component Library") end)

    ~H"""
    <.sidebar_layout>
      <:sidebar>
        <.heading tag={:h1} size={:lg}>
          <.link patch={URL.index()}><%= @title %></.link>
        </.heading>
        <section :for={{module, components} <- @modules}>
          <.heading tag={:h3} size={:md} decoration={:spaced_uppcase}>
            <%= Helpers.pretty_module(module) %>
          </.heading>
          <.navigation orientation={:vertical} items={build_component_items(components)}>
            <.navigation_item
              :for={{_, component} <- components}
              url={URL.component(component)}
              nav={:patch}
              state={nav_item_state(@current_component, component)}
            >
              <%= component.name %>
            </.navigation_item>
          </.navigation>
        </section>
      </:sidebar>
      <:main><%= @live_action %>
        <%= inspect(@current_component) %></:main>
    </.sidebar_layout>
    """
  end

  # ----------------------------------------
  # helpers
  # ----------------------------------------
  defp nav_item_state(%Component{name: :name}, %Component{name: :name}), do: :selected
  defp nav_item_state(_component_1, _component_2), do: :default

  defp find_component(_components, _component_name, %Component{} = component), do: component

  defp find_component(components, component_name, _acc) do
    result = Enum.find(components, fn {name, _comp} -> name == component_name end)

    case result do
      {_, component} -> component
      _ -> nil
    end
  end

  defp build_component_items(components) do
    for {_, component} <- components do
      %{url: URL.component(component), nav: :patch, item: component}
    end
  end

  defp get_current_theme(params) do
    with theme_name when is_binary(theme_name) <- Map.get(params, "theme"),
         %Theme{} = theme <- BuenaVista.Config.find_theme(theme_name) do
      theme
    else
      _ -> BuenaVista.Config.get_default_theme()
    end
  end
end
