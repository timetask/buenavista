defmodule BuenaVista.Bundle do
  defmodule Nomenclator do
    defstruct [:parent, :module_name, :file]
  end

  defmodule Hydrator do
    defstruct [:parent, :module_name, :file]
  end

  defmodule Css do
    defstruct [:out_dir]
  end

  defstruct [
    :name,
    :apps,
    :nomenclator,
    :hydrator,
    :css
  ]
end
