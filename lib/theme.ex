defmodule BuenaVista.Theme do
  use TypedStruct

  defmodule Nomenclator do
    typedstruct enforce: true do
      field :module, atom()
      field :parent_module, atom()
      field :file, String.t()
      field :overridable?, boolean()
    end
  end

  defmodule Hydrator do
    typedstruct enforce: true do
      field :module, atom()
      field :parent_module, atom()
      field :file, String.t()
      field :imports, list(String.t())
      field :overridable?, boolean()
    end
  end

  defmodule App do
    typedstruct enforce: true do
      field :name, atom()
      field :nomenclator, Nomenclator.t()
      field :hydrator, Hydrator.t()
    end
  end

  typedstruct enforce: true do
    field :apps, list(App.t())
    field :name, String.t()
    field :default?, boolean()
    field :gen_css?, boolean()
    field :extend, atom()
    field :css_dir, String.t() | None
    field :themes_dir, String.t() | None
  end
end
