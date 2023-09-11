defmodule BuenaVista.Gallery.GalleryLive do
  use Phoenix.LiveView,
    layout: {Timetask.LayoutsHTML, :base}

  # import BuenaVista
  # import BuenaVista.CssSigil

  alias BuenaVista.Bundle
  alias BuenaVista.Helpers

  # HTML escaping functionality
  # import Phoenix.HTML

  # Shortcut for generating JS commands
  # alias Phoenix.LiveView.JS

  @impl true
  def mount(params, _session, socket) do
    bundle = get_current_bundle(params)
    modules = Helpers.find_component_modules(bundle)

    {:ok,
     socket
     |> assign(:page_title, "Gallery")
     |> assign(:modules, modules)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Hello Gallery</div>
    <div :for={{module, components} <- @modules}>
      <h4><%= Helpers.pretty_module(module) %></h4>
      <a :for={{_, component} <- components} href="">
        <%= component.name %>
      </a>
    </div>
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
