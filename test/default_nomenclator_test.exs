defmodule BuenaVista.DefaultNomenclatorTest do
  use ExUnit.Case
  alias BuenaVista.Template.DefaultNomenclator

  test "Component variant option concatenation" do
    assert DefaultNomenclator.class_name(:first, :second, :third) == "first-third"
  end

  test "Extra classes" do
    assert DefaultNomenclator.class_name(:first, :classes, :third) == "third"
  end

  test "Base class" do
    assert DefaultNomenclator.class_name(:first, :classes, :base_class) == "first"
  end
end
