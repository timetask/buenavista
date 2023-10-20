defmodule BuenaVista.CssTokenizer do
  use TypedStruct

  defmodule Property do
    typedstruct enforce: true do
      field :attr, String.t()
      field :value, String.t()
    end
  end

  defmodule Apply do
    typedstruct enforce: true do
      field :value, String.t()
    end
  end

  defmodule Scope do
    typedstruct enforce: true do
      field :selector, String.t()
      field :tokens, list()
    end
  end

  def build_tokens(contents) do
    contents
    |> to_charlist()
    |> :css_lexer.string()
    |> then(fn {:ok, tokens, _} -> tokens end)
    |> Enum.reduce(%{level: 0, tokens: []}, fn
      {:property, _, {key, val}}, %{level: level, tokens: tokens} ->
        prop = %Property{attr: key, value: val}
        tokens = insert_element(tokens, prop, level)
        %{level: level, tokens: tokens}

      {:apply, _, value}, %{level: level, tokens: tokens} ->
        apply = %Apply{value: value}
        tokens = insert_element(tokens, apply, level)
        %{level: level, tokens: tokens}

      {:start_scope, _, selectors}, %{level: level, tokens: tokens} ->
        scope = %Scope{selector: selectors, tokens: []}
        tokens = insert_element(tokens, scope, level)
        %{level: level + 1, tokens: tokens}

      {:end_scope, _}, %{level: level, tokens: tokens} ->
        %{level: level - 1, tokens: tokens}
    end)
    |> then(fn %{tokens: ast} -> ast end)
  end

  defp insert_element(tokens, ele, 0) do
    [ele | tokens]
  end

  defp insert_element(tokens, prop, level) do
    {scope, tokens_rest} = List.pop_at(tokens, 0)
    tokens = insert_element(scope.tokens, prop, level - 1)
    [%{scope | tokens: tokens} | tokens_rest]
  end

  def sort_tokens(tokens) do
    tokens
    |> Enum.sort(&compare/2)
    |> Enum.map(fn
      %Scope{} = scope ->
        tokens = sort_tokens(scope.tokens)
        %Scope{scope | tokens: tokens}

      property ->
        property
    end)
  end

  defp compare(%Apply{} = a, %Apply{} = b), do: a <= b
  defp compare(%Apply{}, _), do: true
  defp compare(_, %Apply{}), do: false

  defp compare(%Property{}, %Scope{}), do: true
  defp compare(%Scope{}, %Property{}), do: false

  defp compare(%Property{} = a, %Property{} = b),
    do: BuenaVista.CssProperties.property_index(a.attr) >= BuenaVista.CssProperties.property_index(b.attr)

  defp compare(%Scope{} = a, %Scope{} = b), do: BuenaVista.CssProperties.scope_first?(a.selector, b.selector)
end
