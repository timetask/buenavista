defmodule BuenaVista.ConfigReader do
  import Macro, only: [camelize: 1, underscore: 1]

  @doc """
    Validates and converts :buenavista config options into a list
    of %BuenaVista.Themes{}.
  """
  @buenavista_config_schema [
    apps: [
      type:
        {:list,
         {:non_empty_keyword_list,
          [
            name: [required: true, type: :atom],
            nomenclator: [required: false, type: :atom, default: BuenaVista.Themes.DefaultNomenclator],
            hydrator: [required: false, type: :atom, default: BuenaVista.Themes.DefaultHydrator]
          ]}}
    ],
    config: [
      type: :non_empty_keyword_list,
      required: true,
      keys: [
        extend: [required: true, type: {:in, [:hydrator, :nomenclator]}],
        base_module: [required: true, type: :atom],
        themes_dir: [required: true, type: :string],
        css_dir: [required: true, type: :string],
        hydrator_imports: [required: false, type: {:list, :atom}]
      ]
    ],
    themes: [
      type:
        {:list,
         {:non_empty_keyword_list,
          [
            name: [required: true, type: :string],
            parent: [required: false, type: :string],
            default?: [required: false, type: :boolean, default: false],
            gen_css?: [required: false, type: :boolean, default: true]
          ]}}
    ]
  ]

  def build_themes(config) do
    case NimbleOptions.validate(config, @buenavista_config_schema) do
      {:ok, validated_config} ->
        do_build_themes(validated_config)

      {:error, errors} ->
        raise "Failed to load :buenavista config:\n\n#{inspect(errors)}\n\n#{inspect(config)}"
    end
  end

  defp do_build_themes(validated_config) do
    config = Keyword.get(validated_config, :config)
    base_module = Keyword.get(config, :base_module)
    extend = Keyword.get(config, :extend)
    themes_dir = Keyword.get(config, :themes_dir)
    css_dir = Keyword.get(config, :css_dir)
    hydrator_imports = Keyword.get(config, :hydrator_imports)

    for theme_config <- Keyword.get(validated_config, :themes) do
      theme_name = Keyword.get(theme_config, :name)
      parent_theme_name = Keyword.get(theme_config, :parent)

      apps =
        for app_config <- Keyword.get(validated_config, :apps) do
          app_name = Keyword.get(app_config, :name)

          app_nomenclator = %BuenaVista.Theme.Nomenclator{
            parent: BuenaVista.Themes.EmptyNomenclator,
            module_name: Keyword.get(app_config, :nomenclator),
            overridable?: false,
            file: nil
          }

          app_hydrator = %BuenaVista.Theme.Hydrator{
            parent: BuenaVista.Themes.EmptyHydrator,
            module_name: Keyword.get(app_config, :hydrator),
            imports: [],
            overridable?: false,
            file: nil
          }

          {nomenclator, hydrator} =
            case {extend, parent_theme_name} do
              {_any, nil} ->
                {app_nomenclator, app_hydrator}

              {:nomenclator, parent} when is_binary(parent) ->
                module_name = module_name(app_name, theme_name, base_module, :nomenclator)
                file = config_file_path(app_name, theme_name, themes_dir, :nomenclator)

                leaf_nomenclator = %BuenaVista.Theme.Nomenclator{
                  parent: nil,
                  module_name: module_name,
                  file: file,
                  overridable?: true
                }

                {leaf_nomenclator, app_hydrator}

              {:hydrator, parent} when is_binary(parent) ->
                module_name = module_name(app_name, theme_name, base_module, :hydrator)
                file = config_file_path(app_name, theme_name, themes_dir, :hydrator)

                leaf_hydrator = %BuenaVista.Theme.Hydrator{
                  parent: nil,
                  module_name: module_name,
                  file: file,
                  imports: hydrator_imports,
                  overridable?: true
                }

                {app_nomenclator, leaf_hydrator}
            end

          %BuenaVista.Theme.App{
            name: app_name,
            nomenclator: nomenclator,
            hydrator: hydrator
          }
        end

      %BuenaVista.Theme{
        apps: apps,
        name: theme_name,
        extend: extend,
        default?: Keyword.get(theme_config, :default?),
        gen_css?: Keyword.get(theme_config, :gen_css?),
        themes_dir: themes_dir,
        css_dir: css_dir
      }
    end
  end

  @doc """
  Generates module names for nomenclators and hydrators

  iex> module_name(:buenavista, "admin", MyApp.Themes, :nomenclator)
  MyApp.Themes.AdminBuenvistaNomenclator

  iex> module_name(:my_components, "admin_light", MyApp.Themes, :nomenclator)
  MyApp.Themes.AdminMyComponentsLightNomenclator

  iex> module_name(:buenavista, "admin_dark", MyApp.Config.Themes, :hydrator)
  MyApp.Config.Themes.AdminDarkHydrator
  """
  def module_name(app_name, theme_name, base_module_name, module_type) when module_type in [:nomenclator, :hydrator] do
    Module.concat([base_module_name, camelize(theme_name), camelize("#{app_name}_#{module_type}")])
  end

  @doc """
  Generates the path where to write the specified module.

  iex> config_file_path(:buenavista, "admin", "/tmp/themes", :nomenclator)
  "/tmp/themes/admin_buenavista_nomenclator.ex"

  iex> config_file_path(:my_app, "admin_dark", "lib/components/config", :hydrator)
  "lib/components/config/admin_my_app_dark_hydrator.ex"
  """
  def config_file_path(app_name, theme_name, out_dir, module_type) when module_type in [:nomenclator, :hydrator] do
    filename = "#{underscore(Atom.to_string(app_name))}_#{module_type}.ex"

    Path.join([out_dir, underscore(theme_name), filename])
  end
end
