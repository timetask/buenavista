defmodule BuenaVista.Gallery.URL do
  @config Application.compile_env(:buenavista, :gallery)

  def index() do
    base_url()
  end

  def component(%BuenaVista.Component{} = component) do
    Path.join(base_url(), Atom.to_string(component.name))
  end

  defp base_url() do
    Keyword.get(@config, :base_url)
  end
end
