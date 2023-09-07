defmodule BuenaVista.CssSigil do
  defmacro sigil_CSS({:<<>>, _, [binary]}, []) when is_binary(binary), do: binary
end
