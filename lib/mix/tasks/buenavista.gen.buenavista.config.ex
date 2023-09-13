defmodule Mix.Tasks.Buenavista.Gen.Buenavista.Config do
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
        apps: [:buenavista],
        nomenclator: BuenaVista.Template.DefaultNomenclator,
        hydrator: [
          parent: BuenaVista.Template.EmptyHydrator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template"
        ],
        css: [out_dir: nil]
      ],
      [
        name: "tailwind",
        apps: [:buenavista],
        nomenclator: BuenaVista.Template.DefaultNomenclator,
        hydrator: [
          parent: BuenaVista.Template.EmptyHydrator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template"
        ],
        css: [out_dir: nil]
      ],
      [
        name: "tailwind_inline",
        apps: [:buenavista],
        nomenclator: [
          parent: BuenaVista.Template.EmptyNomenclator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template"
        ],
        hydrator: nil,
        css: [out_dir: nil]
      ],
      [
        name: "bootstrap",
        apps: [:buenavista],
        nomenclator: [
          parent: BuenaVista.Template.EmptyNomenclator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template"
        ],
        hydrator: nil,
        css: [out_dir: nil]
      ],
      [
        name: "bulma",
        apps: [:buenavista],
        nomenclator: [
          parent: BuenaVista.Template.EmptyNomenclator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template"
        ],
        hydrator: nil,
        css: [out_dir: nil]
      ],
      [
        name: "foundation",
        apps: [:buenavista],
        nomenclator: [
          parent: BuenaVista.Template.EmptyNomenclator,
          base_module_name: BuenaVista.Template,
          out_dir: "lib/template"
        ],
        hydrator: nil,
        css: [out_dir: nil]
      ]
    ]

    for bundle <- bundles do
      %BuenaVista.Bundle{} = bundle = BuenaVista.Helpers.build_bundle(bundle)
      BuenaVista.Generator.sync_config(bundle)
    end
  end
end
