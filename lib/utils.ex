defmodule BuenaVista.Utils do
  import Macro, only: [camelize: 1, underscore: 1]

  alias BuenaVista.Bundle

  @doc """
  Generates module names for nomenclators and hydrators

  iex> module_name(%Bundle{name: "admin", config_base_module: MyApp.Components.Config}, :nomenclator)
  MyApp.Components.Config.AdminNomenclator

  iex> module_name(%Bundle{name: "admin_light", config_base_module: MyApp.Components.Config}, :nomenclator)
  MyApp.Components.Config.AdminLightNomenclator

  iex> module_name(%Bundle{name: "admin_dark", config_base_module: MyApp.Components}, :hydrator)
  MyApp.Components.AdminDarkHydrator
  """
  def module_name(%Bundle{} = bundle, module_type) when module_type in [:nomenclator, :hydrator] do
    Module.concat([bundle.config_base_module, camelize("#{bundle.name}_#{module_type}")])
  end

  @doc """
  Generates the path where to write the specified module.

  iex> config_file_path(%Bundle{name: "admin", config_out_dir: "/tmp/config"}, :nomenclator)
  "/tmp/config/admin_nomenclator.ex"

  iex> config_file_path(%Bundle{name: "admin_dark", config_out_dir: "lib/components/config"}, :hydrator)
  "lib/components/config/admin_dark_hydrator.ex"
  """
  def config_file_path(%Bundle{} = bundle, module_type) when module_type in [:nomenclator, :hydrator] do
    filename = "#{underscore(bundle.name)}_#{module_type}.ex"

    Path.join(bundle.config_out_dir, filename)
  end
end
