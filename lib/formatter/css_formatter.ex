defmodule BuenaVista.CssFormatter do
  @behaviour Mix.Tasks.Format

  @impl true
  def features(_opts) do
    [sigils: [:CSS], extensions: []]
  end

  @impl true
  def format(contents, _opts) do
    contents
    |> BuenaVista.CssTokenizer.build_tokens()
    |> BuenaVista.CssTokenizer.sort_tokens()
    |> write_rules()
  end


  def write_rules(rules) when is_list(rules) do
    rules
    |> Enum.reduce([], fn rule, acc -> write_rule(rule, 0, acc) end)
    |> Enum.reverse()
    |> :erlang.iolist_to_binary()
  end

  defp write_rule(%BuenaVista.CssTokenizer.Scope{} = scope, level, acc) do
    acc = ["\n#{indent(level + 1)}#{scope.selector} {\n" | acc]
    acc = Enum.reduce(scope.rules, acc, fn child_rules, child_acc -> write_rule(child_rules, level + 1, child_acc) end)
    ["#{indent(level + 1)}}\n" | acc]
  end

  defp write_rule(%BuenaVista.CssTokenizer.Property{} = prop, level, acc) do
    ["#{indent(level + 1)}#{prop.attr}: #{prop.value};\n" | acc]
  end

  defp write_rule(%BuenaVista.CssTokenizer.Apply{} = apply, level, acc) do
    ["#{indent(level + 1)}@apply #{apply.value};\n" | acc]
  end

  defp indent(level) do
    String.duplicate("  ", level)
  end
end
