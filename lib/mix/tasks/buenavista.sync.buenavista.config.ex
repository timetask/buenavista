defmodule Mix.Tasks.Buenavista.Sync.Buenavista.Config do
  @moduledoc """
  Syncs BuenaVista's base nomenclators and hydrators with the librarie's
  components configurations.

  It's purpose is to help BuenaVista development.
  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(_opts) do
    bundles = [
      [
        name: :css,
        component_apps: [:buenavista],
        parent_hydrator: BuenaVista.Template.EmptyHydrator,
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        produce_css: false
      ],
      [
        name: :tailwind,
        parent_hydrator: BuenaVista.Template.EmptyHydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        produce_css: false
      ],
      [
        name: :tailwind_inline,
        parent_nomenclator: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        produce_css: false
      ],
      [
        name: :bootstrap,
        parent_nomenclator: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        produce_css: false
      ],
      [
        name: :bulma,
        parent_nomenclator: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        produce_css: false
      ],
      [
        name: :foundation,
        parent_nomenclator: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        produce_css: false
      ]
    ]

    Application.put_env(:buenavista, :bundles, bundles)
    Mix.Tasks.Buenavista.Sync.Config.run([])
  end
end
