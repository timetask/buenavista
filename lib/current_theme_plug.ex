defmodule BuenaVista.CurrentThemePlug do
  def init(opts), do: opts

  def call(conn, _opts) do
    {:ok, theme} =
      if theme_name = conn.query_params["theme"] do
        case BuenaVista.Themes.find_theme(theme_name) do
          {:ok, theme} -> {:ok, theme}
          {:error, :not_found} -> BuenaVista.Themes.get_default_theme()
        end
      else
        case Plug.Conn.get_session(conn, :theme) do
          %BuenaVista.Theme{} = theme -> {:ok, theme}
          _ -> BuenaVista.Themes.get_default_theme()
        end
      end

    conn
    |> Plug.Conn.put_session(:theme, theme)
    |> Plug.Conn.assign(:theme, theme)
  end
end
