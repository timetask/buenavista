defmodule BuenaVista.Helpers do
  import Macro, only: [camelize: 1, underscore: 1]
  import IO.ANSI
  alias BuenaVista.Theme

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

  @doc """
  Generates module names for nomenclators and hydrators

  iex> module_name("admin", MyApp.Components.Config, :nomenclator)
  MyApp.Components.Config.AdminNomenclator

  iex> module_name("admin_light", MyApp.Components.Config, :nomenclator)
  MyApp.Components.Config.AdminLightNomenclator

  iex> module_name("admin_dark", MyApp.Components, :hydrator)
  MyApp.Components.AdminDarkHydrator
  """
  def module_name(name, base_module_name, module_type) when module_type in [:nomenclator, :hydrator] do
    Module.concat([base_module_name, camelize("#{name}_#{module_type}")])
  end

  @doc """
  Generates the path where to write the specified module.

  iex> config_file_path("admin", "/tmp/config", :nomenclator)
  "/tmp/config/admin_nomenclator.ex"

  iex> config_file_path( "admin_dark",  "lib/components/config", :hydrator)
  "lib/components/config/admin_dark_hydrator.ex"
  """
  def config_file_path(name, out_dir, module_type) when module_type in [:nomenclator, :hydrator] do
    filename = "#{underscore(name)}_#{module_type}.ex"

    Path.join(out_dir, filename)
  end

  def pretty_module(module) do
    module |> Atom.to_string() |> String.replace("Elixir.", "")
  end

  @doc """
  Converts config keyword list en Theme structs.
  """
  def build_theme(theme) when is_list(theme) do
    name =
      Keyword.get(theme, :name) ||
        raise "Theme config error: missing key :name. Provided theme: #{inspect(theme)}"

    name = underscore(name)

    hydrator =
      case Keyword.get(theme, :hydrator) do
        hydrator_conf when is_list(hydrator_conf) ->
          base_module_name = Keyword.get(hydrator_conf, :base_module_name)
          out_dir = Keyword.get(hydrator_conf, :out_dir)

          hydrator_module_name = module_name(name, base_module_name, :hydrator)
          hydrator_file = config_file_path(name, out_dir, :hydrator)

          %Theme.Hydrator{
            parent: Keyword.get(hydrator_conf, :parent),
            module_name: hydrator_module_name,
            file: hydrator_file,
            imports: Keyword.get(hydrator_conf, :imports, [])
          }

        module when is_atom(module) ->
          module
      end

    nomenclator =
      case Keyword.get(theme, :nomenclator) do
        nomenclator_conf when is_list(nomenclator_conf) ->
          base_module_name = Keyword.get(nomenclator_conf, :base_module_name)
          out_dir = Keyword.get(nomenclator_conf, :out_dir)

          nomenclator_module_name = module_name(name, base_module_name, :nomenclator)
          nomenclator_file = config_file_path(name, out_dir, :nomenclator)

          %Theme.Nomenclator{
            parent: Keyword.get(nomenclator_conf, :parent),
            module_name: nomenclator_module_name,
            file: nomenclator_file
          }

        module when is_atom(module) ->
          module
      end

    css =
      if css_conf = Keyword.get(theme, :css),
        do: %Theme.Css{
          out_dir: Keyword.get(css_conf, :out_dir)
        },
        else: nil

    %Theme{
      name: name,
      hydrator: hydrator,
      nomenclator: nomenclator,
      css: css
    }
  end

  def get_nomenclator(%Theme{} = theme) do
    case theme.nomenclator do
      %Theme.Nomenclator{module_name: module_name} -> module_name
      module_name -> module_name
    end
  end

  def get_hydrator(%Theme{} = theme) do
    case theme.hydrator do
      %Theme.Hydrator{module_name: module_name} -> module_name
      module_name -> module_name
    end
  end

  def last_module_alias(module) do
    module.__info__(:module)
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> underscore()
  end

  def write_and_format_module(file_path, content) do
    filename = for _ <- 1..5, into: "", do: <<Enum.random(~c"0123456789abcdef")>>
    tmp_file = "/tmp/tmp_#{filename}.ex"
    :ok = File.write(tmp_file, content)
    System.cmd("mix", ["format", tmp_file])
    File.rename(tmp_file, file_path)
    IO.puts(green() <> "* creating " <> reset() <> file_path)
  end
end
