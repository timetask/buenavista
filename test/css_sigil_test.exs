defmodule BuenaVista.CssSigilTest do
  use ExUnit.Case
  import BuenaVista.CssSigils

  describe "~VAR[]" do
    test "simple strings go untouched" do
      assert {"hello", "hello"} == ~VAR[hello]
    end

    test ~S|Functions get wrapped in #{}| do
      assert {"floor(21.4)", ~S|#{floor(21.4)}|} == ~VAR[floor(21.4)]
    end

    test "Works for multiple functions" do
      assert {"floor(1) ceil(2.2)", ~S|#{floor(1)} #{ceil(2.2)}|} == ~VAR[floor(1) ceil(2.2)]
    end
  end

  describe "~CSS" do
    test "Replaces $var with <%= @var %>" do
      assert ~CSS[color: $red;] =~ "color: <%= @red %>;"
    end

    test "Replaces can handle $var_a_2 " do
      assert ~CSS[color: $var_a_2;] =~ "color: <%= @var_a_2 %>;"
    end

    test "Replaces $component__class with <%= class_name(:component, :classes, :class) %>" do
      assert ~CSS[$component__base_class] =~ "<%= class_name(:component, :classes, :base_class) %>"
    end

    test "Replaces $component__variant__option with <%= class_name(:name, :variant, :option) %>" do
      assert ~CSS[$a__b__c] =~ "<%= class_name(:a, :b, :c) %>"
    end
  end
end
