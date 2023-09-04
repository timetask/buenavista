defmodule BuenaVista.ComponentFinder do
  def find_component_modules() do
    modules =
      for {app, _desc, _version} <- :application.loaded_applications(),
          {:ok, modules} = :application.get_key(app, :modules),
          module <- modules,
          Code.ensure_loaded(module),
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
