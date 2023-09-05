defmodule BuenaVista.Generator.Utils do
  import Macro, only: [camelize: 1, underscore: 1]

  @doc """
  Generates module names for nomenclators and hydrators

  iex> module_name(:my_app_web, :nomenclator, :tailwind_inline, nil)
  MyAppWeb.Components.Config.TailwindInlineNomenclator

  iex> module_name(:my_app, :hydrator, :vanilla, nil)
  MyApp.Components.Config.VanillaHydrator

  iex> module_name(:buenavista, :nomenclator, :vanilla, nil)
  BuenaVista.Nomenclator.Vanilla

  iex> module_name(:buenavista, :hydrator, :tailwind_classes, nil)
  BuenaVista.Hydrator.TailwindClasses

  iex> module_name(:my_app_web, :hydrator, :tailwind_classes, "dark_mode")
  MyAppWeb.Components.Config.DarkModeHydrator

  iex> module_name(:my_app_web, :nomenclator, :bulma, "light_mode")
  MyAppWeb.Components.Config.LightModeNomenclator
  """
  def module_name(bundle, module_type) when is_list(bundle) do
    base_module = Keyword.get(bundle, :config_base_module)
    name = Keyword.get(bundle, :name)
    name = if is_atom(name), do: Atom.to_string(name), else: name

    Module.concat([base_module, camelize(name <> "_#{module_type}")])
  end

  def uses_hydrator?(:external_hydrator), do: false
  def uses_hydrator?(:internal_hydrator), do: true

  def uses_hydrator?(:css), do: true
  def uses_hydrator?(:css_dark), do: true
  def uses_hydrator?(:css_light), do: true
  def uses_hydrator?(:tailwind), do: true
  def uses_hydrator?(:tailwind_dark), do: true
  def uses_hydrator?(:tailwind_light), do: true

  def uses_hydrator?(:tailwind_inline), do: false
  def uses_hydrator?(:bootstrap), do: false
  def uses_hydrator?(:bulma), do: false
  def uses_hydrator?(:foundation), do: false

  def delegate_nomenclator(bundle) do
    case Keyword.get(bundle, :style) do
      :internal_hydrator -> BuenaVista.Template.DefaultNomenclator
      :external_hydrator -> nil
      :css -> BuenaVista.Templates.CssNomenclator
      :css_list -> BuenaVista.Templates.CssNomenclator
      :bootstrap -> BuenaVista.Nomenclator.Bootstrap
      :bulma -> BuenaVista.Nomenclator.Bulma
      :foundation -> BuenaVista.Nomenclator.Foundation
      :vanilla_dark -> BuenaVista.Nomenclator.Default
      :vanilla_light -> BuenaVista.Nomenclator.Default
    end
  end

  def parent_nomenclator(_rest), do: BuenaVista.Nomenclator.Default

  def delegate_hydrator(bundle) do
    case Keyword.get(bundle, :style) do
      :tailwind_classes -> BuenaVista.Hydrator.TailwindClasses
      :vanilla_dark -> BuenaVista.Hydrator.VanillaDark
      :vanilla_light -> BuenaVista.Hydrator.VanillaLight
    end
  end

  @doc """
  Generates the path where to write the specified module.

  iex> file_path(:buenavista, :nomenclator, :tailwind_inline, nil)
  "lib/nomenclator/tailwind_inline.ex"

  iex> file_path(:buenavista, :hydrator, :vanilla, nil)
  "lib/hydrator/vanilla.ex"

  iex> file_path(:my_app_web, :hydrator, :tailwind_classes, "apps/my_app_web/components/config")
  "apps/my_app_web/components/config/tailwind_classes_hydrator.ex"

  iex> path = file_path(:my_app_web, :nomenclator, :bootstrap, nil)
  iex> path =~ "lib/my_app_web/components/config/bootstrap_nomenclator.ex"
  true
  """
  def config_file_path(bundle, module_type) do
    name = Keyword.get(bundle, :name)
    name = if is_atom(name), do: Atom.to_string(name), else: name
    config_out_dir = Keyword.get(bundle, :config_out_dir)
    filename = "#{underscore(name)}_#{module_type}.ex"

    Path.join(config_out_dir, filename)
  end
end
