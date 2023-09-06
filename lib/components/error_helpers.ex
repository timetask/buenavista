defmodule BuenaVista.Components.ErrorHelpers do
  import BuenaVista.Config, only: [gettext: 0]

  def error_text({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(gettext(), "errors", msg, msg, count, opts)
      |> String.capitalize()
    else
      Gettext.dgettext(gettext(), "errors", msg, opts) |> String.capitalize()
    end
  end

  def errors_for(%{errors: errors}, field) do
    errors
    |> Keyword.get_values(field)
    |> Enum.map(fn {msg, opts} ->
      if count = opts[:count] do
        Gettext.dngettext(gettext(), "errors", msg, msg, count, opts)
      else
        Gettext.dgettext(gettext(), "errors", msg, opts)
      end
    end)
  end

  def errors_for(_form, _field), do: []
end
