defmodule BuenaVista.Constants.DefaultSizes do
  def size(0), do: "0px"
  def size(0.25), do: "0.125rem"
  def size(0.5), do: "0.125rem"
  def size(1), do: "0.25rem"
  def size(1.5), do: "0.375rem"
  def size(2), do: "0.5rem"
  def size(2.5), do: "0.625rem"
  def size(3), do: "0.75rem"
  def size(3.5), do: "0.875rem"
  def size(4), do: "1rem"
  def size(5), do: "1.25rem"
  def size(6), do: "1.5rem"
  def size(7), do: "1.75rem"
  def size(8), do: "2rem"
  def size(9), do: "2.25rem"
  def size(10), do: "2.5rem"
  def size(11), do: "2.75rem"
  def size(12), do: "3rem"
  def size(14), do: "3.5rem"
  def size(16), do: "4rem"
  def size(20), do: "5rem"
  def size(24), do: "6rem"
  def size(28), do: "7rem"
  def size(32), do: "8rem"
  def size(36), do: "9rem"
  def size(40), do: "10rem"
  def size(44), do: "11rem"
  def size(48), do: "12rem"
  def size(52), do: "13rem"
  def size(56), do: "14rem"
  def size(60), do: "15rem"
  def size(64), do: "16rem"
  def size(72), do: "18rem"
  def size(80), do: "20rem"
  def size(96), do: "24rem"

  def size(:font, :xs), do: size(2)
  def size(:font, :sm), do: size(3)
  def size(:font, :md), do: size(4)
  def size(:font, :lg), do: size(6)
  def size(:font, :xl), do: size(8)
end
