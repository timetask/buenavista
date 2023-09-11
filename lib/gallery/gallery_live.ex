defmodule BuenaVista.Gallery.GalleryLive do
  use Phoenix.LiveView,
    layout: {Timetask.LayoutsHTML, :base}

  import BuenaVista
  import BuenaVista.CssSigil

  # HTML escaping functionality
  import Phoenix.HTML

  # Shortcut for generating JS commands
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Gallery")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Hello Gallery</div>
    """
  end
end
