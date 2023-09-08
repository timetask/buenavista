defmodule BuenaVista.CssFormatter do
  @behaviour Mix.Tasks.Format
  import BuenaVista.CssProperties, only: [property_index: 1, scope_index: 1]

  defmodule Property do
    defstruct [:attr, :value]
  end

  defmodule Scope do
    defstruct [:selector, :rules]
  end

  @impl true
  def features(_opts) do
    [sigils: [:CSS], extensions: []]
  end

  @impl true
  def format(contents, _opts) do
    contents
    |> build_ast()
    |> sort_rules()
    |> write_rules()
  end

  defp build_ast(contents) do
    contents
    |> to_charlist()
    |> :css_lexer.string()
    |> then(fn {:ok, rules, _} -> rules end)
    |> Enum.reduce(%{level: 0, rules: []}, fn
      {:property, _, {key, val}}, %{level: level, rules: rules} ->
        prop = %Property{attr: key, value: val}
        rules = insert_element(rules, prop, level)
        %{level: level, rules: rules}

      {:start_scope, _, selectors}, %{level: level, rules: rules} ->
        scope = %Scope{selector: selectors, rules: []}
        rules = insert_element(rules, scope, level)
        %{level: level + 1, rules: rules}

      {:end_scope, _}, %{level: level, rules: rules} ->
        %{level: level - 1, rules: rules}
    end)
    |> then(fn %{rules: ast} -> ast end)
  end

  defp insert_element(rules, ele, 0) do
    [ele | rules]
  end

  defp insert_element(rules, prop, level) do
    {scope, rules_rest} = List.pop_at(rules, 0)
    rules = insert_element(scope.rules, prop, level - 1)
    [%{scope | rules: rules} | rules_rest]
  end

  defp sort_rules(rules) do
    rules
    |> Enum.sort(&compare/2)
    |> Enum.map(fn
      %Scope{} = scope ->
        rules = sort_rules(scope.rules)
        %Scope{scope | rules: rules}

      property ->
        property
    end)
  end

  defp compare(%Property{}, %Scope{}), do: true
  defp compare(%Scope{}, %Property{}), do: false
  defp compare(%Property{} = a, %Property{} = b), do: property_index(a.attr) >= property_index(b.attr)
  defp compare(%Scope{} = a, %Scope{} = b), do: scope_index(a.selector) <= scope_index(b.selector)

  def write_rules(rules) do
    rules
    |> Enum.reduce([], fn rule, acc -> expand_rule(rule, 0, acc) end)
    |> Enum.reverse()
    |> :erlang.iolist_to_binary()
    |> then(fn body -> "\n" <> body end)
  end

  defp expand_rule(%Scope{} = scope, level, acc) do
    acc = ["\n#{String.duplicate("  ", level + 2)}#{scope.selector} {\n" | acc]
    acc = Enum.reduce(scope.rules, acc, fn child_rules, child_acc -> expand_rule(child_rules, level + 1, child_acc) end)
    ["#{String.duplicate("  ", level + 2)}}\n" | acc]
  end

  defp expand_rule(%Property{} = prop, level, acc) do
    ["#{String.duplicate("  ", level + 2)}#{prop.attr}: #{prop.value};\n" | acc]
  end
end
