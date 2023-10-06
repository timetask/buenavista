defmodule BuenaVista.HydratorTest do
  use ExUnit.Case

  describe "style macro: " do
    test "Stores class definition" do
      defmodule ClassDefStyle do
        use BuenaVista.Hydrator

        style :component, :class_key, ~CSS"""
          color: blue;
        """
      end

      styles = ClassDefStyle.get_styles_map()
      assert %BuenaVista.Hydrator.Style{} = Map.get(styles, {:component, :classes, :class_key})
    end

    test "Stores option style definition" do
      defmodule OptionDefStyle do
        use BuenaVista.Hydrator

        style :component, :variant, :option, ~CSS"""
          color: blue;
        """
      end

      styles = OptionDefStyle.get_styles_map()
      assert %BuenaVista.Hydrator.Style{} = Map.get(styles, {:component, :variant, :option})
    end
  end

  describe "var macro: " do
    test "Allow binary variables" do
      defmodule BinaryVar do
        use BuenaVista.Hydrator

        var :padding, "4px"
      end

      variable = Keyword.get(BinaryVar.get_variables(), :padding)
      assert variable.key == :padding
      assert variable.css_value == "4px"
      assert variable.property == %{type: :raw_value}
    end

    test "Allow integer variables" do
      defmodule IntegerVar do
        use BuenaVista.Hydrator

        var :padding, 0
      end

      variable = Keyword.get(IntegerVar.get_variables(), :padding)
      assert variable.key == :padding
      assert variable.css_value == "0"
      assert variable.property == %{type: :raw_value}
    end

    test "Allow atom variables" do
      defmodule AtomVar do
        use BuenaVista.Hydrator

        var :color, :red
      end

      variable = Keyword.get(AtomVar.get_variables(), :color)
      assert variable.key == :color
      assert variable.css_value == "red"
      assert variable.property == %{type: :raw_value}
    end
  end

  describe "~VAR macro: " do
    test "Can use kernel functions" do
      defmodule KernelFuncVar do
        use BuenaVista.Hydrator

        var :padding, ~VAR[floor(2.1)]
      end

      variable = Keyword.get(KernelFuncVar.get_variables(), :padding)
      assert variable.key == :padding
      assert variable.css_value == "\x02"
      assert variable.property == %{type: :var, raw_body: "floor(2.1)"}
    end

    test "Can use imported functions" do
      defmodule ImportedFuncVar do
        use BuenaVista.Hydrator
        import BuenaVista.Constants.DefaultSizes

        var :padding, ~VAR[size(2)]
      end

      variable = Keyword.get(ImportedFuncVar.get_variables(), :padding)
      assert variable.key == :padding
      assert variable.css_value == "0.5rem"
      assert variable.property == %{type: :var, raw_body: "size(2)"}
    end

    test "Can use multiple functions" do
      defmodule MultipleFuncVar do
        use BuenaVista.Hydrator
        import BuenaVista.Constants.DefaultSizes

        var :padding, ~VAR[size(2) size(4)]
      end

      variable = Keyword.get(MultipleFuncVar.get_variables(), :padding)
      assert variable.key == :padding
      assert variable.css_value == "0.5rem 1rem"
      assert variable.property == %{type: :var, raw_body: "size(2) size(4)"}
    end
  end
end
