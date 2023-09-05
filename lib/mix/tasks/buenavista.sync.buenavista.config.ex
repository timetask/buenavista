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
        style: :internal_hydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Templates
      ],
      [
        name: :tailwind,
        style: :internal_hydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Templates
      ],
      [
        name: :tailwind_inline,
        style: :external_hydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Templates
      ],
      [
        name: :bootstrap,
        style: :external_hydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Templates
      ],
      [
        name: :bulma,
        style: :external_hydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Templates
      ],
      [
        name: :foundation,
        style: :external_hydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Templates
      ]
    ]

    Application.put_env(:buenavista, :bundles, bundles)
    Mix.Tasks.Buenavista.Sync.Config.run([])
  end
end
