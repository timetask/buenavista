defmodule BuenaVista.CssFormatterTest do
  use ExUnit.Case
  import BuenaVista.CssFormatter

  describe "format/2" do
    test "Nested formatting" do
      css = """
                      background: green;
        border: 1px solid red;
                      .non-nested {
      display: none;
      }
      &:hover, .other {
      .nested { height: 45px;
      }
      color: black;
      background: blue;
      }
      """

      result = format(css, [])

      assert result ==
               """
                 background: green;
                 border: 1px solid red;

                 &:hover, .other {
                   background: blue;
                   color: black;

                   .nested {
                     height: 45px;
                   }
                 }

                 .non-nested {
                   display: none;
                 }
               """
    end

    test "properties form a straight line" do
      css = """
                      background: green;
        border: 1px solid red;
      display: block;
              padding: 1px;
        margin: $margin_big;
                      * {
        display: none;
            height: 45px;
                    color: black;
        background: blue;
      }
      """

      result = format(css, [])

      assert result ==
               """
                 background: green;
                 border: 1px solid red;
                 padding: 1px;
                 margin: $margin_big;
                 display: block;

                 * {
                   background: blue;
                   color: black;
                   height: 45px;
                   display: none;
                 }
               """
    end

    test "allow elements and selector" do
      css = """
        color: blue;

        code {
          color: green;
        }
      """

      result = format(css, [])

      assert result == """
               color: blue;

               code {
                 color: green;
               }
             """
    end

    test "reading @apply" do
      css = """
                 @apply text-blue-400;
           .nested {
             @apply bg-green-100;
             }
      """

      result = format(css, [])

      assert result ==
               """
                 @apply text-blue-400;

                 .nested {
                   @apply bg-green-100;
                 }
               """
    end

    test "allow variables" do
      css = """
                  background: <%= @app_bg %>;
      """

      result = format(css, [])

      assert result == """
               background: <%= @app_bg %>;
             """
    end

    test "allow class_name call at scope begin" do
      css = """
              color: yellow;    .<%= class_name(:component, :variant, :name) %> {background: blue;}
      """

      result = format(css, [])

      assert result == """
               color: yellow;

               .<%= class_name(:component, :variant, :name) %> {
                 background: blue;
               }
             """
    end
  end
end
