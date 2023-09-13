defmodule BuenaVista.Gallery.GalleryLive do
  use Phoenix.LiveView,
    layout: {Timetask.LayoutsHTML, :base}

  import BuenaVista
  # import BuenaVista.CssSigil

  alias BuenaVista.Bundle
  alias BuenaVista.Gallery.URL
  alias BuenaVista.Helpers

  # HTML escaping functionality
  # import Phoenix.HTML

  # Shortcut for generating JS commands
  # alias Phoenix.LiveView.JS
  @config Application.compile_env(:buenavista, :gallery)

  @impl true
  def mount(params, _session, socket) do
    bundle = get_current_bundle(params)
    modules = Helpers.find_component_modules(bundle.apps)

    {:ok,
     socket
     |> assign(:page_title, "Gallery")
     |> assign(:modules, modules)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assign_new(assigns, :title, fn -> Keyword.get(@config, :sidebar_title, "BuenaVista Component Library") end)

    ~H"""
    <.sidebar_layout>
      <:sidebar>
        <h1><%= @title %></h1>
        <div :for={{module, components} <- @modules}>
          <h4><%= Helpers.pretty_module(module) %></h4>
          <.link :for={{_, component} <- components} navigate={URL.component(component)}>
            <%= component.name %>
          </.link>
        </div>
      </:sidebar>
      <:main>Main content</:main>
    </.sidebar_layout>
    """
  end

  defp get_current_bundle(params) do
    with bundle_name when is_binary(bundle_name) <- Map.get(params, "bundle"),
         %Bundle{} = bundle <- BuenaVista.Config.find_bundle(bundle_name) do
      bundle
    else
      _ -> BuenaVista.Config.get_default_bundle()
    end
  end
end
