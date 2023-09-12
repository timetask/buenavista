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
    Mix.Task.run("app.config")

    bundles = [
      [
        name: "css",
        component_apps: [:buenavista],
        hydrator_parent: BuenaVista.Template.EmptyHydrator,
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        css_out_dir: nil
      ],
      [
        name: "tailwind",
        hydrator_parent: BuenaVista.Template.EmptyHydrator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        css_out_dir: nil
      ],
      [
        name: "tailwind_inline",
        nomenclator_parent: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        css_out_dir: nil
      ],
      [
        name: "bootstrap",
        nomenclator_parent: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        css_out_dir: nil
      ],
      [
        name: "bulma",
        nomenclator_parent: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        css_out_dir: nil
      ],
      [
        name: "foundation",
        nomenclator_parent: BuenaVista.Template.EmptyNomenclator,
        component_apps: [:buenavista],
        config_out_dir: "lib/template",
        config_base_module: BuenaVista.Template,
        css_out_dir: nil
      ]
    ]

    for bundle <- bundles do
      %BuenaVista.Bundle{} = bundle = BuenaVista.Config.pack_bundle(bundle)
      BuenaVista.Generator.sync(bundle)
    end
  end
end
