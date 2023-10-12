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

    {themes, _cache} =
      for theme_config <- Keyword.get(validated_config, :themes), reduce: {[], %{}} do
        {themes, cache} ->
          {apps, cache} =
            for app_config <- Keyword.get(validated_config, :apps), reduce: {[], cache} do
              {apps, cache} ->
                cache_key = cache_key(Keyword.get(theme_config, :name), Keyword.get(app_config, :name))

                {nomenclator, hydrator} = get_app_nomenclator_and_hydrator(config, theme_config, app_config, cache)

                app = %BuenaVista.Theme.App{
                  name: Keyword.get(app_config, :name),
                  nomenclator: nomenclator,
                  hydrator: hydrator
                }

                cache_entry = %{nomenclator: nomenclator.module, hydrator: hydrator.module}
                cache = Map.put(cache, cache_key, cache_entry)

                {[app | apps], cache}
            end

          theme = %BuenaVista.Theme{
            apps: apps,
            name: Keyword.get(theme_config, :name),
            extend: Keyword.get(config, :extend),
            default?: Keyword.get(theme_config, :default?),
            gen_css?: Keyword.get(theme_config, :gen_css?),
            themes_dir: Keyword.get(config, :themes_dir),
            css_dir: Keyword.get(config, :css_dir)
          }

          {[theme | themes], cache}
      end

    Enum.reverse(themes)
  end

  defp cache_key(theme_name, app_name) do
    "#{theme_name}-#{app_name}"
  end

  defp get_app_nomenclator_and_hydrator(config, theme_config, app_config, cache) do
    base_module = Keyword.get(config, :base_module)
    extend = Keyword.get(config, :extend)
    themes_dir = Keyword.get(config, :themes_dir)
    hydrator_imports = Keyword.get(config, :hydrator_imports)
    theme_name = Keyword.get(theme_config, :name)
    parent_theme_name = Keyword.get(theme_config, :parent)
    app_name = Keyword.get(app_config, :name)
    cache_key = cache_key(parent_theme_name, app_name)

    app_nomenclator = %BuenaVista.Theme.Nomenclator{
      module: Keyword.get(app_config, :nomenclator, BuenaVista.Themes.EmptyNomenclator),
      parent_module: BuenaVista.Themes.EmptyNomenclator,
      overridable?: false,
      file: nil
    }

    app_hydrator = %BuenaVista.Theme.Hydrator{
      module: Keyword.get(app_config, :hydrator, BuenaVista.Themes.EmptyHydrator),
      parent_module: BuenaVista.Themes.EmptyHydrator,
      imports: [],
      overridable?: false,
      file: nil
    }

    case extend do
      :nomenclator ->
        module = module_name(app_name, theme_name, base_module, :nomenclator)
        parent_module = get_in(cache, [cache_key, :hydrator]) || app_nomenclator.module
        file = config_file_path(app_name, theme_name, themes_dir, :nomenclator)

        nomenclator = %BuenaVista.Theme.Nomenclator{
          module: module,
          parent_module: parent_module,
          file: file,
          overridable?: true
        }

        {nomenclator, app_hydrator}

      :hydrator ->
        module = module_name(app_name, theme_name, base_module, :hydrator)
        parent_module = get_in(cache, [cache_key, :hydrator]) || app_hydrator.module
        file = config_file_path(app_name, theme_name, themes_dir, :hydrator)

        hydrator = %BuenaVista.Theme.Hydrator{
          module: module,
          parent_module: parent_module,
          file: file,
          imports: hydrator_imports,
          overridable?: true
        }

        {app_nomenclator, hydrator}
    end
  end

  @doc """
  Generates module names for nomenclators and hydrators

  iex> module_name(:buenavista, "admin", MyApp.Themes, :nomenclator)
  MyApp.Themes.Admin.BuenavistaNomenclator

  iex> module_name(:my_components, "admin_light", MyApp.Themes, :nomenclator)
  MyApp.Themes.AdminLight.MyComponentsNomenclator

  iex> module_name(:buenavista, "admin_dark", MyApp.Config.Themes, :hydrator)
  MyApp.Config.Themes.AdminDark.BuenavistaHydrator
  """
  def module_name(app_name, theme_name, base_module, module_type) when module_type in [:nomenclator, :hydrator] do
    Module.concat([base_module, camelize(theme_name), camelize("#{app_name}_#{module_type}")])
  end

  @doc """
  Generates the path where to write the specified module.

  iex> config_file_path(:buenavista, "admin", "/tmp/themes", :nomenclator)
  "/tmp/themes/admin/buenavista_nomenclator.ex"

  iex> config_file_path(:my_app, "admin_dark", "lib/themes", :hydrator)
  "lib/themes/admin_dark/my_app_hydrator.ex"
  """
  def config_file_path(app_name, theme_name, out_dir, module_type) when module_type in [:nomenclator, :hydrator] do
    filename = "#{underscore(Atom.to_string(app_name))}_#{module_type}.ex"

    Path.join([out_dir, underscore(theme_name), filename])
  end
end
