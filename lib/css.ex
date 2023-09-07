defmodule BuenaVista.CSS do
  defmacro sigil_CSS({:<<>>, _, [binary]}, []) when is_binary(binary), do: binary
end
