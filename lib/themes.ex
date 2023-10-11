defmodule BuenaVista.Themes do
  alias BuenaVista.Helpers

  @default_theme_name ""

  @themes (
            apps = Application.compile_env(:buenavista, :apps)
            config = Application.compile_env(:buenavista, :config)
            themes = Application.compile_env(:buenavista, :themes)
            Helpers.build_themes(apps: apps, config: config, themes: themes)
          )

  def get_themes(), do: @themes

  def find_theme(theme_name) when is_binary(theme_name) do
    case Enum.find(get_themes(), fn theme -> theme.name == theme_name end) do
      %BuenaVista.Theme{} = theme -> {:ok, theme}
      _ -> {:error, :not_found}
    end
  end

  def get_default_theme() do
    find_theme(@default_theme_name)
  end

  def current_nomenclator() do
    BuenaVista.Themes.DefaultNomenclator
  end

  def available_themes() do
    Application.get_env(:buenavista, :themes)
  end

  def gettext() do
    Application.get_env(:buenvista, :gettext)
  end
end
