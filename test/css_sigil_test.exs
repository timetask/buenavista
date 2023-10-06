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
      css = ~CSS"""
        color: $red;
      """

      assert css =~ "color: <%= @red %>;"
    end

    test "Detects multiple variables" do
      css = ~CSS"""
        background: $blue;
        color: $red;

        &:hover {
          border-color: $green;
        }
      """

      assert css =~ "color: <%= @red %>;"
      assert css =~ "background: <%= @blue %>;"
      assert css =~ "border-color: <%= @green %>;"
    end
  end
end
