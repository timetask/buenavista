defmodule BuenaVista.Bundle do
  defstruct [
    :name,
    :nomenclator,
    :hydrator,
    :component_apps,
    :config_out_dir,
    :config_base_module,
    :css_out_dir
  ]
end
