defmodule BuenaVista.CssSigils do
  @func_pattern ~r/([a-zA-Z]{1}[a-zA-Z0-9_]*\([a-zA-Z0-9.,:\s_]*\))/

  defmacro sigil_CSS({:<<>>, _, [binary]}, []) when is_binary(binary), do: binary

  defmacro sigil_VAR({:<<>>, _, [raw_body]}, []) do
    formatted_body =
      Regex.replace(@func_pattern, raw_body, "#\{\\0\}", global: true)

    {raw_body, formatted_body}
  end
end
