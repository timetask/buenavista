defmodule BuenaVista.Config do
  alias BuenaVista.Helpers

  @default_theme_name Application.compile_env(:buenavista, :default_theme)

  @themes (for theme <- Application.compile_env(:buenavista, :themes) || [] do
             Helpers.build_theme(theme)
           end)

  def get_themes(), do: @themes

  def find_theme(theme_name) when is_binary(theme_name) do
    Enum.find(get_themes(), fn theme -> theme.name == theme_name end)
  end

  def get_default_theme() do
    find_theme(@default_theme_name)
  end

  def current_nomenclator() do
    BuenaVista.Template.DefaultNomenclator
  end

  def available_themes() do
    Application.get_env(:buenavista, :themes)
  end

  def gettext() do
    Application.get_env(:buenvista, :gettext)
  end
end
