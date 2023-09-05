defmodule BuenaVista.Config do
  @supported_templates [
    :internal_hydrator,
    :css,
    :tailwind,
    :external_hydrator,
    :tailwind_inline,
    :bootstrap,
    :bulma,
    :foundation
  ]

  def get_current_nomenclator() do
    BuenaVista.Template.DefaultNomenclator
  end

  def get_available_bundles() do
    Application.get_env(:buenavista, :bundles)
  end

  def supported_templates() do
    @supported_templates
  end
end
