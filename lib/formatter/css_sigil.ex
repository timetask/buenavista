defmodule BuenaVista.CssSigils do
  @var_pattern ~r/(?!.*__)\$([a-z_]*)/
  @class_pattern ~r/(?=.*__)\$([a-z_]*)/
  @func_pattern ~r/([a-zA-Z]{1}[a-zA-Z0-9_]*\([a-zA-Z0-9.,:\s_]*\))/

  defmacro sigil_CSS({:<<>>, _, [raw_body]}, []) when is_binary(raw_body) do
    replaced_vars =
      Regex.replace(@var_pattern, raw_body, "<%= @\\1 %>", global: true)

    Regex.replace(@class_pattern, replaced_vars, fn original, captured_class_var ->
      case String.split(captured_class_var, "__") do
        [component, class_key] -> "<%= class_name(:#{component}, :classes, :#{class_key}) %>"
        [component, variant, option] -> "<%= class_name(:#{component}, :#{variant}, :#{option}) %>"
        _ -> original
      end
    end)
  end

  defmacro sigil_VAR({:<<>>, _, [raw_body]}, []) do
    formatted_body =
      Regex.replace(@func_pattern, raw_body, "#\{\\0\}", global: true)

    {raw_body, formatted_body}
  end
end
