defmodule BuenaVista.CssFormatterTest do
  use ExUnit.Case
  import BuenaVista.CssFormatter
  import BuenaVista.CssSigil

  describe "format/2" do
    test "Nested formatting" do
      css = ~S|background: green;
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
|
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
  end
end
