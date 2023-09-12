defmodule BuenaVista.Helpers do
  import Macro, only: [camelize: 1, underscore: 1]

  alias BuenaVista.Bundle

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
        components -> {module, components}
      end
    end
    |> Enum.reject(&is_nil/1)
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
  Converts config keyword list en Bundle structs.
  """
  def build_bundle(bundle) when is_list(bundle) do
    name =
      Keyword.get(bundle, :name) ||
        raise "Bundle config error: missing key :name. Provided bundle: #{inspect(bundle)}"

    name = underscore(name)

    apps =
      Keyword.get(bundle, :apps) ||
        raise "Bundle config error: missing key :apps. Provided bundle: #{inspect(bundle)}"

    unless is_list(apps) do
      raise ":apps in bundle #{inspect(bundle)} must be a list of apps."
    end

    hydrator =
      case Keyword.get(bundle, :hydrator) do
        hydrator_conf when is_list(hydrator_conf) ->
          base_module_name = Keyword.get(hydrator_conf, :base_module_name)
          out_dir = Keyword.get(hydrator_conf, :out_dir)

          hydrator_module_name = module_name(name, base_module_name, :hydrator)
          hydrator_file = config_file_path(name, out_dir, :hydrator)

          %Bundle.Hydrator{
            parent: Keyword.get(hydrator_conf, :parent),
            module_name: hydrator_module_name,
            file: hydrator_file
          }

        module when is_atom(module) ->
          module
      end

    nomenclator =
      case Keyword.get(bundle, :nomenclator) do
        nomenclator_conf when is_list(nomenclator_conf) ->
          base_module_name = Keyword.get(nomenclator_conf, :base_module_name)
          out_dir = Keyword.get(nomenclator_conf, :out_dir)

          nomenclator_module_name = module_name(name, base_module_name, :nomenclator)
          nomenclator_file = config_file_path(name, out_dir, :nomenclator)

          %Bundle.Nomenclator{
            parent: Keyword.get(nomenclator_conf, :parent),
            module_name: nomenclator_module_name,
            file: nomenclator_file
          }

        module when is_atom(module) ->
          module
      end

    css =
      if css_conf = Keyword.get(bundle, :css),
        do: %Bundle.Css{
          out_dir: Keyword.get(css_conf, :out_dir)
        },
        else: nil

    %Bundle{
      name: name,
      apps: apps,
      hydrator: hydrator,
      nomenclator: nomenclator,
      css: css
    }
  end
end
