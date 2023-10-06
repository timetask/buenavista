defmodule BuenaVista.CssSigils do
  @var_pattern ~r/(?!.*__)\$([a-z_]*)/
  @func_pattern ~r/([a-zA-Z]{1}[a-zA-Z0-9_]*\([a-zA-Z0-9.,:\s_]*\))/

  defmacro sigil_CSS({:<<>>, _, [raw_body]}, []) when is_binary(raw_body) do
    formatted_body =
      Regex.replace(@var_pattern, raw_body, "<%= @\\1 %>", global: true)

    formatted_body
  end

  defmacro sigil_VAR({:<<>>, _, [raw_body]}, []) do
    formatted_body =
      Regex.replace(@func_pattern, raw_body, "#\{\\0\}", global: true)

    {raw_body, formatted_body}
  end
end
