defmodule BuenaVista.Helpers do
  import Macro, only: [underscore: 1]

  def get_component_modules_from_cache(%BuenaVista.Theme.App{} = app, modules_cache) do
    case Map.get(modules_cache, app.name) do
      nil ->
        modules = BuenaVista.Helpers.find_component_modules([app])
        {modules, Map.put(modules_cache, app.name, modules)}

      modules ->
        {modules, modules_cache}
    end
  end

  @doc """
  Returns all BuenaVista modules and components.
  """
  def find_component_modules(apps) when is_list(apps) do
    modules =
      for %BuenaVista.Theme.App{} = app <- apps,
          spec = Application.spec(app.name),
          module <- Keyword.get(spec, :modules),
          {:module, module} = Code.ensure_loaded(module),
          reduce: [] do
        acc ->
          if function_exported?(module, :are_you_buenavista?, 0),
            do: [module | acc],
            else: acc
      end

    for module <- modules do
      case module.get_buenavista_components() do
        [] -> nil
        components -> {module, Enum.reverse(components)}
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.reverse()
  end

  def find_app_name(module_file) when is_binary(module_file) do
    module_file
    |> Path.dirname()
    |> find_app_name_in_dir()
  end

  defp find_app_name_in_dir(dir) do
    {:ok, files} = File.ls(dir)

    if "mix.exs" in files do
      mix_file = Path.join(dir, "mix.exs")
      {:ok, content} = File.read(mix_file)

      case Regex.named_captures(~r/app: :(?<app_name>[a-z_]+),*\n/, content) do
        %{"app_name" => app_name} -> String.to_existing_atom(app_name)
        _ -> raise("Failed to read an app name from #{mix_file}")
      end
    else
      dir |> Path.dirname() |> find_app_name_in_dir()
    end
  end

  def pretty_module(module) when is_atom(module) do
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
    {formatter, opts} = Mix.Tasks.Format.formatter_for_file("helpers.ex")
    :ok = File.write(file_path, formatter.(content))
    IO.puts(IO.ANSI.green() <> "* creating " <> IO.ANSI.reset() <> file_path)
  end
end
