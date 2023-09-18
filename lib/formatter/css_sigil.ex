defmodule BuenaVista.CssSigils do
  defmacro sigil_CSS({:<<>>, _, [binary]}, []) when is_binary(binary), do: binary

  defmacro sigil_VAR({:<<>>, _, [func_body]}, []) do
    {:function, func_body}
  end
end
