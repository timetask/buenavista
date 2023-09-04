defmodule Buenavista.ButtonTest do
  use ExUnit.Case

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import BuenaVista.Components.Button

  describe "button/1" do
    test "default rendering" do
      assigns = %{}

      {:ok, [element]} =
        ~H[<.button>Press Me</.button>]
        |> rendered_to_string()
        |> Floki.parse_fragment()

      assert Floki.attribute(element, "class") == ["button button-md button-ctrl button-filled button-border-thin"]
      assert Floki.attribute(element, "type") == ["button"]
      assert Floki.text(element) =~ "Press Me"
    end

    for {size, class} <- [xs: "xs", sm: "sm", md: "md", lg: "lg"] do
      test ~s|attribute size set to :#{size} adds class "#{class}"| do
        assigns = %{size: unquote(size)}

        {:ok, [element]} =
          ~H[<.button size={@size} />]
          |> rendered_to_string()
          |> Floki.parse_fragment()

        [class] = Floki.attribute(element, "class")
        assert class =~ unquote(class)
      end
    end

    for {color, class} <- [
          nav: "nav",
          ctrl: "ctrl",
          primary: "primary",
          success: "success",
          warning: "warning",
          info: "info",
          danger: "danger"
        ] do
      test ~s|attribute color set to :#{color} adds class "#{class}"| do
        assigns = %{color: unquote(color)}

        {:ok, [element]} =
          ~H[<.button color={@color} />]
          |> rendered_to_string()
          |> Floki.parse_fragment()

        [rendered_class] = Floki.attribute(element, "class")
        assert rendered_class =~ unquote(class)
      end
    end

    for {style, class} <- [outline: "outline", transparent: "transparent", filled: "filled", link: "link"] do
      test ~s|attribute style set to :#{style} adds class "#{class}"| do
        assigns = %{style: unquote(style)}

        {:ok, [element]} =
          ~H[<.button style={@style} />]
          |> rendered_to_string()
          |> Floki.parse_fragment()

        [rendered_class] = Floki.attribute(element, "class")
        assert rendered_class =~ unquote(class)
      end
    end

    for {border, class} <- [none: nil, thin: "thin", thick: "thick"] do
      test ~s|attribute border set to :#{border} adds class "#{class}"| do
        assigns = %{border: unquote(border)}

        {:ok, [element]} =
          ~H[<.button border={@border} />]
          |> rendered_to_string()
          |> Floki.parse_fragment()

        [rendered_class] = Floki.attribute(element, "class")

        if is_nil(unquote(class)) do
          assert not (rendered_class =~ "border")
        else
          assert rendered_class =~ unquote(class)
        end
      end
    end
  end
end
