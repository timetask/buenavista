defmodule Mix.Tasks.Bv.Gen.Css do
  use Mix.Task
  require Logger

  @requirements ["app.config"]
  @shortdoc "Generates CSS files (use `--help` for options)"
  def run(opts) do
    {parsed, _, _} = OptionParser.parse(opts, strict: [bundle: :keep], aliases: [b: :bundle])

    BuenaVista.Config.get_bundles()
    |> maybe_filter_bundles_by_name(parsed)
    |> BuenaVista.Generator.generate_css_files()
  end

  defp maybe_filter_bundles_by_name(bundles, parsed_opts) do
    filter_bundle_names = Keyword.get_values(parsed_opts, :bundle)

    if Enum.empty?(filter_bundle_names),
      do: bundles,
      else: Enum.filter(bundles, fn bundle -> bundle.name in filter_bundle_names end)
  end
end
