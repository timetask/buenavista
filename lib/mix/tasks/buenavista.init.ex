defmodule Mix.Tasks.Buenavista.Init do
  @moduledoc """
  Generates both Nomenclator and Hydrator modules to be used to configure
  both BuenaVista and your own components. 

  Usage: 

      mix buenavista.init [options] 

  Examples:

      $ mix buenavista.init --style tailwind_classes --out apps/my_app/lib/components/config
      $ mix buenavista.init -n components -s vanilla -o lib/my_app_web/buenavista

  Options:

  -n, --name                 Used to create Nomenclature and Hydrator module and
                             file name. By default the name is derived from style.
  -s, --style                Framework & style to be used.
                             Options:
                             - tailwind_inline
                             - tailwind_classes
                             - bootstrap
                             - bulma
                             - foundation
                             - vanilla
                             Default: vanilla
  -o, --out                  Output directory. Use relative path from project root.
                             Default lib/<your_app>_web/components/config
  -h, --help                 Show this help
  """
  use Mix.Task

  alias BuenaVista.Generator

  @shortdoc "Generates an initial Nomenclator and Hydrator modules"
  def run(opts) do
    Mix.Task.run("app.config")

    {parsed, _args, _errors} =
      OptionParser.parse(opts,
        aliasses: [n: :name, s: :style, o: :out, h: :help],
        strict: [name: :string, style: :string, out: :string, help: :boolean]
      )

    name = Keyword.get(parsed, :name)
    style = Keyword.get(parsed, :style, "vanilla") |> String.to_existing_atom()
    out_dir = Keyword.get(parsed, :out)
    help = Keyword.get(parsed, :help)

    if help do
      IO.puts(@moduledoc)
    else
      {:ok, app_name} = :application.get_application(__MODULE__)

      Generator.init(app_name, out_dir, style, name)
    end
  end
end
