defmodule BuenaVista.Theme do
  use TypedStruct

  defmodule Nomenclator do
    typedstruct do
      field :parent, atom()
      field :module_name, atom()
      field :file, String.t()
    end
  end

  defmodule Hydrator do
    typedstruct do
      field :parent, atom()
      field :module_name, atom()
      field :file, String.t()
      field :imports, list(String.t())
    end
  end

  defmodule App do
    typedstruct do
      field :name, atom()
      field :nomenclator, Nomenclator.t()
      field :hydrator, Hydrator.t()
    end
  end

  typedstruct do
    field :apps, list(App.t())
    field :name, String.t()
    field :default?, boolean()
    field :gen_css?, boolean()
    field :extend, atom()
    field :css_dir, String.t() | None
    field :themes_dir, String.t() | None
  end
end
