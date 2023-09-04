defmodule Mix.Tasks.Buenavista.Sync.Nomenclator do
  @moduledoc """
  Generates an empty Nomenclator Module. The role of a nomenclator is 
  to provide class names for all components.

  Usage: 

      mix buenavista.gen.nomenclator [options] 

  Examples:

      $ mix buenavista.gen.nomenclator --name bootstrap --out /tmp/path
      $ mix buenavista.gen.nomenclator -n light -o /code/

  Options:

  -n, --name                 Gives name to the generated module and filename
  -o, --out                  Output directory. Default lib/config/buenavista
  -h, --help                 Show this help

  """
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @shortdoc "Syncronizes Nomenclator and Hydrator modules for your project"
  def run(opts) do
    {parsed, _args, _errors} =
      OptionParser.parse(opts,
        aliasses: [n: :name, o: :out, h: :help],
        strict: [name: :string, out: :string, help: :boolean]
      )

    name = Keyword.get(parsed, :name)
    style = Keyword.get(parsed, :style, "vanilla") |> String.to_existing_atom()
    out_dir = Keyword.get(parsed, :out)
    help = Keyword.get(parsed, :help)

    if help do
      IO.puts(@moduledoc)
    else
    {:ok, app_name} = :application.get_application(__MODULE__)
      Generator.sync(app_name, out_dir, style, name)
    end
  end
end
