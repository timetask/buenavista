defmodule BuenaVista.ConfigReaderTest do
  use ExUnit.Case
  import BuenaVista.ConfigReader

  doctest BuenaVista.ConfigReader

  describe "build_themes/1" do
    test "happy path setup" do
      config = [
        apps: [
          [name: :buenavista_components, hydrator: BuenaVista.Themes.DefaultHydrator],
          [name: :timetask]
        ],
        config: [
          base_module: TestApp.Themes,
          extend: :hydrator,
          themes_dir: "lib/themes",
          css_dir: "lib/assets/themes",
          hydrator_imports: [
            BuenaVista.Constants.TailwindColors,
            BuenaVista.Constants.TailwindSizes
          ]
        ],
        themes: [
          [name: "base", gen_css?: false],
          [name: "dark", parent: "base"],
          [name: "light", parent: "base", default?: true]
        ]
      ]

      themes = BuenaVista.ConfigReader.build_themes(config)
      base_theme = Enum.find(themes, fn theme -> theme.name == "base" end)
      light_theme = Enum.find(themes, fn theme -> theme.name == "light" end)
      dark_theme = Enum.find(themes, fn theme -> theme.name == "dark" end)

      assert base_theme ==
               %BuenaVista.Theme{
                 themes_dir: "lib/themes",
                 css_dir: "lib/assets/themes",
                 extend: :hydrator,
                 gen_css?: false,
                 default?: false,
                 name: "base",
                 apps: [
                   %BuenaVista.Theme.App{
                     hydrator: %BuenaVista.Theme.Hydrator{
                       overridable?: true,
                       imports: [BuenaVista.Constants.TailwindColors, BuenaVista.Constants.TailwindSizes],
                       file: "lib/themes/base/timetask_hydrator.ex",
                       parent_module: BuenaVista.Themes.EmptyHydrator,
                       module: TestApp.Themes.Base.TimetaskHydrator
                     },
                     nomenclator: %BuenaVista.Theme.Nomenclator{
                       overridable?: false,
                       file: nil,
                       parent_module: BuenaVista.Themes.EmptyNomenclator,
                       module: BuenaVista.Themes.DefaultNomenclator
                     },
                     name: :timetask
                   },
                   %BuenaVista.Theme.App{
                     hydrator: %BuenaVista.Theme.Hydrator{
                       overridable?: true,
                       imports: [BuenaVista.Constants.TailwindColors, BuenaVista.Constants.TailwindSizes],
                       file: "lib/themes/base/buenavista_components_hydrator.ex",
                       parent_module: BuenaVista.Themes.DefaultHydrator,
                       module: TestApp.Themes.Base.BuenavistaComponentsHydrator
                     },
                     nomenclator: %BuenaVista.Theme.Nomenclator{
                       overridable?: false,
                       file: nil,
                       parent_module: BuenaVista.Themes.EmptyNomenclator,
                       module: BuenaVista.Themes.DefaultNomenclator
                     },
                     name: :buenavista_components
                   }
                 ]
               }

      assert dark_theme ==
               %BuenaVista.Theme{
                 themes_dir: "lib/themes",
                 css_dir: "lib/assets/themes",
                 extend: :hydrator,
                 gen_css?: true,
                 default?: false,
                 name: "dark",
                 apps: [
                   %BuenaVista.Theme.App{
                     hydrator: %BuenaVista.Theme.Hydrator{
                       overridable?: true,
                       imports: [BuenaVista.Constants.TailwindColors, BuenaVista.Constants.TailwindSizes],
                       file: "lib/themes/dark/timetask_hydrator.ex",
                       parent_module: TestApp.Themes.Base.TimetaskHydrator,
                       module: TestApp.Themes.Dark.TimetaskHydrator
                     },
                     nomenclator: %BuenaVista.Theme.Nomenclator{
                       overridable?: false,
                       file: nil,
                       parent_module: BuenaVista.Themes.EmptyNomenclator,
                       module: BuenaVista.Themes.DefaultNomenclator
                     },
                     name: :timetask
                   },
                   %BuenaVista.Theme.App{
                     hydrator: %BuenaVista.Theme.Hydrator{
                       overridable?: true,
                       imports: [BuenaVista.Constants.TailwindColors, BuenaVista.Constants.TailwindSizes],
                       file: "lib/themes/dark/buenavista_components_hydrator.ex",
                       parent_module: TestApp.Themes.Base.BuenavistaComponentsHydrator,
                       module: TestApp.Themes.Dark.BuenavistaComponentsHydrator
                     },
                     nomenclator: %BuenaVista.Theme.Nomenclator{
                       overridable?: false,
                       file: nil,
                       parent_module: BuenaVista.Themes.EmptyNomenclator,
                       module: BuenaVista.Themes.DefaultNomenclator
                     },
                     name: :buenavista_components
                   }
                 ]
               }

      assert light_theme ==
               %BuenaVista.Theme{
                 themes_dir: "lib/themes",
                 css_dir: "lib/assets/themes",
                 extend: :hydrator,
                 gen_css?: true,
                 default?: true,
                 name: "light",
                 apps: [
                   %BuenaVista.Theme.App{
                     hydrator: %BuenaVista.Theme.Hydrator{
                       overridable?: true,
                       imports: [BuenaVista.Constants.TailwindColors, BuenaVista.Constants.TailwindSizes],
                       file: "lib/themes/light/timetask_hydrator.ex",
                       parent_module: TestApp.Themes.Base.TimetaskHydrator,
                       module: TestApp.Themes.Light.TimetaskHydrator
                     },
                     nomenclator: %BuenaVista.Theme.Nomenclator{
                       overridable?: false,
                       file: nil,
                       parent_module: BuenaVista.Themes.EmptyNomenclator,
                       module: BuenaVista.Themes.DefaultNomenclator
                     },
                     name: :timetask
                   },
                   %BuenaVista.Theme.App{
                     hydrator: %BuenaVista.Theme.Hydrator{
                       overridable?: true,
                       imports: [BuenaVista.Constants.TailwindColors, BuenaVista.Constants.TailwindSizes],
                       file: "lib/themes/light/buenavista_components_hydrator.ex",
                       parent_module: TestApp.Themes.Base.BuenavistaComponentsHydrator,
                       module: TestApp.Themes.Light.BuenavistaComponentsHydrator
                     },
                     nomenclator: %BuenaVista.Theme.Nomenclator{
                       overridable?: false,
                       file: nil,
                       parent_module: BuenaVista.Themes.EmptyNomenclator,
                       module: BuenaVista.Themes.DefaultNomenclator
                     },
                     name: :buenavista_components
                   }
                 ]
               }
    end

    test "fails when no default themes" do
      config = [
        apps: [[name: :app]],
        config: [
          base_module: TestApp.Themes,
          extend: :hydrator,
          themes_dir: "lib/themes",
          css_dir: "lib/assets/themes"
        ],
        themes: [
          [name: "base", gen_css?: false],
          [name: "dark", parent: "base"],
          [name: "light", parent: "base"]
        ]
      ]

      assert_raise ArgumentError, ~r/.*provide exactly one default theme.*/, fn ->
        BuenaVista.ConfigReader.build_themes(config)
      end
    end

    test "fails when more than one default" do
      config = [
        apps: [[name: :app]],
        config: [
          base_module: TestApp.Themes,
          extend: :hydrator,
          themes_dir: "lib/themes",
          css_dir: "lib/assets/themes"
        ],
        themes: [
          [name: "base", gen_css?: false],
          [name: "dark", parent: "base", default?: true],
          [name: "light", parent: "base", default?: true]
        ]
      ]

      assert_raise ArgumentError, ~r/.*provide exactly one default theme.*/, fn ->
        BuenaVista.ConfigReader.build_themes(config)
      end
    end
  end
end
