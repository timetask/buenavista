defmodule BuenaVista.CssFormatter do
  @behaviour Mix.Tasks.Format

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

  defp sort_rules(contents) do
    dbg(contents)
    contents
  end

  def write_rules(contents) do
    contents
  end
end
