defmodule Buenavista.Generator.Utils do
  import Macro, only: [camelize: 1]

  @doc """
  Returns *_web base module name for your project.

  iex> sanitize_app_name(:buenavista)
  :buenavista

  iex> sanitize_app_name(:my_app)
  :my_app_web

  iex> sanitize_app_name(:my_app_web)
  :my_app_web
  """
  def sanitize_app_name(app_name) when is_atom(app_name) do
    if app_name == :buenavista do
      :buenavista
    else
      if app_name |> Atom.to_string() |> String.ends_with?("web"),
        do: app_name,
        else: "#{app_name}_web" |> String.to_atom()
    end
  end

  def uses_hydrator?(:tailwind_inline), do: false
  def uses_hydrator?(:bootstrap), do: false
  def uses_hydrator?(:bulma), do: false
  def uses_hydrator?(:foundation), do: false
  def uses_hydrator?(_style), do: true

  def parent_nomenclator(:buenavista, _style), do: BuenaVista.Nomenclator.Default
  def parent_nomenclator(_app_name, :tailwind_inline), do: BuenaVista.Nomenclator.TailwindInline
  def parent_nomenclator(_app_name, :tailwind_classes), do: BuenaVista.Nomenclator.TailwindClasses
  def parent_nomenclator(_app_name, :bootstrap), do: BuenaVista.Nomenclator.Bootstrap
  def parent_nomenclator(_app_name, :bulma), do: BuenaVista.Nomenclator.Bulma
  def parent_nomenclator(_app_name, :foundation), do: BuenaVista.Nomenclator.Foundation
  def parent_nomenclator(_app_name, :rest), do: BuenaVista.Nomenclator.Default

  def parent_hydrator(:buenavista, _style), do: BuenaVista.Hydrator.Empty
  def parent_hydrator(_app_name, :tailwind_classes), do: BuenaVista.Hydrator.TailwindClasses
  def parent_hydrator(_app_name, :vanilla), do: BuenaVista.Hydrator.TailwindClasses

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
  def module_name(app_name, :nomenclator, style, name) when is_atom(app_name) and is_atom(style) do
    name =
      if is_nil(name),
        do: name,
        else: Atom.to_string(style)

    if app_name == :buenavista do
      Module.concat([BuenaVista, Nomenclator, camelize(name)])
    else
      base_module = app_name |> Atom.to_string() |> camelize()
      Module.concat([base_module, Components, Config, camelize(name <> "_nomenclator")])
    end
  end

  def module_name(app_name, :hydrator, style, name) when is_atom(app_name) and is_atom(style) do
    name =
      if is_nil(name),
        do: name,
        else: Atom.to_string(style)

    if app_name == :buenavista do
      Module.concat([BuenaVista, Hydrator, camelize(name)])
    else
      base_module = app_name |> Atom.to_string() |> camelize()
      Module.concat([base_module, Components, Config, camelize(name <> "_hydrator")])
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
  def file_path(app_name, module_type, style, out_dir)
      when is_atom(app_name) and is_atom(module_type) and is_atom(style) do
    directory = final_out_dir(app_name, module_type, out_dir)

    filename =
      if app_name == :buenavista,
        do: "#{style}.ex",
        else: "#{style}_#{module_type}.ex"

    Path.join(directory, filename)
  end

  defp final_out_dir(:buenavista, :nomenclator, _out_dir), do: "lib/nomenclator"
  defp final_out_dir(:buenavista, :hydrator, _out_dir), do: "lib/hydrator"
  defp final_out_dir(app_name, _any_module, nil), do: Path.join(File.cwd!(), "lib/#{app_name}/components/config")
  defp final_out_dir(_app_name, _any_module, out_dir), do: out_dir
end
