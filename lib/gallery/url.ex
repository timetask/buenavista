defmodule BuenaVista.Gallery.URL do
  @config Application.compile_env(:buenavista, :gallery)

  def index() do
    Keyword.get(@config, :base_url)
  end

  def component(%BuenaVista.Component{} = component) do
    base_url = Keyword.get(@config, :base_url)
    Path.join(base_url, Atom.to_string(component.name))
  end
end
