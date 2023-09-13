defmodule BuenaVista.Gallery.URL do
  @base_url Application.compile_env(:buenavista_gallery, :base_url)

  def index() do
    @base_url
  end

  def component(%BuenaVista.Component{} = component) do
    Path.join(@base_url, Atom.to_string(component.name))
  end
end
