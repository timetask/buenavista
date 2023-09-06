defmodule BuenaVista.Gallery.GalleryController do
  use Phoenix.Controller,
    formats: [:html],
    layouts: [html: {BuenaVista.Gallery.LayoutsTemplates, :base}]

  import Plug.Conn

  plug :put_layout, html: {BuenaVista.Gallery.LayoutsTemplates, :base}
  plug :put_view, html: BuenaVista.Gallery.GalleryTemplates

  def dashboard(conn, _opts) do
    render(conn, :dashboard, page_title: "BuenaVista Component Gallery")
  end

  def component(conn, _opts) do
    render(conn, :component, page_title: "TODO: component name")
  end
end
