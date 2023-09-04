defmodule BuenaVista.InputTest do
  use ExUnit.Case

  require BuenaVista.Nomenclator

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import BuenaVista.Components.Input

  alias Phoenix.HTML.FormField

  defp build_field(opts \\ []) do
    %FormField{
      id: Keyword.get(opts, :id, "input-name"),
      name: Keyword.get(opts, :name, "Name"),
      errors: Keyword.get(opts, :errors, []),
      field: Keyword.get(opts, :field, :name),
      form: Keyword.get(opts, :form, nil),
      value: Keyword.get(opts, :value, "Francisco")
    }
  end

  describe "label/1" do
    test "default rendering" do
      assigns = %{field: build_field()}

      {:ok, [element]} =
        ~H[<.label field={@field}>Name</.label>]
        |> rendered_to_string()
        |> Floki.parse_fragment()

      assert Floki.attribute(element, "class") == ["label"]
      assert {"label", _attrs, _children} = element
      assert Floki.text(element) =~ "Name"
    end

    test "can pass text attribute" do
      assigns = %{field: build_field()}

      {:ok, [element]} =
        ~H[<.label field={@field} label="Name" />]
        |> rendered_to_string()
        |> Floki.parse_fragment()

      assert Floki.text(element) =~ "Name"
    end

    for {state, class} <- [success: "label-success", danger: "label-danger"] do
      test "attribute state set to #{state} adds class #{class}" do
        assigns = %{field: build_field(), state: unquote(state)}

        {:ok, [element]} =
          ~H[<.label state={@state} field={@field}></.label>]
          |> rendered_to_string()
          |> Floki.parse_fragment()

        [class] = Floki.attribute(element, "class")
        assert class == "label #{unquote(class)}"
      end
    end
  end

  describe "label/1 config attributes" do
    test "Can assign a state class via module config" do
      defmodule NewNomenclator do
        use BuenaVista.Nomenclator
        @parent BuenaVista.Nomenclator.Default

        def class_name(:label, :state, :danger), do: "peligro!"
      end

      assigns = %{field: build_field(), state: :danger, nomenclator: NewNomenclator}

      {:ok, [element]} =
        ~H[<.label field={@field} state={@state} nomenclator={@nomenclator}></.label>]
        |> rendered_to_string()
        |> Floki.parse_fragment()

      [class] = Floki.attribute(element, "class")
      assert class == "label peligro!"
    end

    test "Can assign a base_class via module config" do
      defmodule NewNomenclator2 do
        use BuenaVista.Nomenclator
        @parent BuenaVista.Nomenclator.Default

        def class_name(:label, :classes, :base_class), do: "form-label"
      end

      assigns = %{field: build_field(), state: :danger, nomenclator: NewNomenclator2}

      {:ok, [element]} =
        ~H[<.label field={@field} state={@state} nomenclator={@nomenclator}></.label>]
        |> rendered_to_string()
        |> Floki.parse_fragment()

      [class] = Floki.attribute(element, "class")
      assert class == "form-label label-danger"
    end

    # TODO: pass keyword to config nomenclature
  end
end
