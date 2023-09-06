defmodule BuenaVista.Finder do
  alias BuenaVista.Bundle

  def find_component_modules(%Bundle{} = bundle) do
    modules =
      for app <- bundle.component_apps,
          spec = Application.spec(app),
          module <- Keyword.get(spec, :modules),
          {:module, module} = Code.ensure_loaded(module),
          reduce: [] do
        acc ->
          if function_exported?(module, :__are_you_buenavista?, 0),
            do: [module | acc],
            else: acc
      end

    for module <- modules do
      case module.__buenavista_components() do
        [] -> nil
        components -> {module, components}
      end
    end
    |> Enum.reject(&is_nil/1)
  end
end
