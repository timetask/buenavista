defmodule BuenaVista.Hydrator.Empty do
  use BuenaVista.Hydrator

  def variables(), do: [color: [red: ["500": "soft-red"]], border: "1px"]
end
