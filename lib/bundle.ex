defmodule BuenaVista.Bundle do
  defstruct [
    :name,
    :parent_hydrator,
    :parent_nomenclator,
    :component_apps,
    :config_out_dir,
    :config_base_module,
    :produce_css
  ]
end
