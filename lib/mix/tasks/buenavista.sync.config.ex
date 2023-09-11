defmodule Mix.Tasks.Buenavista.Sync.Config do
  @moduledoc """

  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(_opts) do
    for %BuenaVista.Bundle{} = bundle <- BuenaVista.Config.get_bundles() do
      BuenaVista.Generator.sync(bundle)
    end
  end
end
