defmodule BuenaVista.Helpers do
  import Macro, only: [underscore: 1]

  @doc """
  Returns all BuenaVista modules and components.
  """
  def find_component_modules(apps) when is_list(apps) do
    modules =
      for app <- apps,
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
        components -> {module, Enum.reverse(components)}
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.reverse()
  end

  def pretty_module(module) do
    module |> Atom.to_string() |> String.replace("Elixir.", "")
  end

  def last_module_alias(module) do
    module.__info__(:module)
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> underscore()
  end

  def write_and_format_module(file_path, content) do
    :ok = file_path |> Path.dirname() |> File.mkdir_p()
    {formatter, _} = Mix.Tasks.Format.formatter_for_file("source.ex")
    File.write(formatter.(content), file_path)
    IO.puts(IO.ANSI.green() <> "* creating " <> IO.ANSI.reset() <> file_path)
  end
end
