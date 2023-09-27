defmodule BuenaVista.Theme do
  defmodule Nomenclator do
    defstruct [:parent, :module_name, :file]
  end

  defmodule Hydrator do
    defstruct [:parent, :module_name, :file, :imports]
  end

  defmodule Css do
    defstruct [:out_dir]
  end

  defstruct [
    :name,
    :nomenclator,
    :hydrator,
    :css
  ]
end
