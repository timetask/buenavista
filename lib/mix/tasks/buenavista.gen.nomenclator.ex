# defmodule Mix.Tasks.Buenavista.Gen.Nomenclator do
#   use Mix.Task
#   require Logger

#   import Macro, only: [camelize: 1, underscore: 1]
#   import Mix.Generator

#   @shortdoc "Generate an empty configuration module."
#   def run(opts) do
#     Mix.Task.run("app.config")

#     {parsed, _args, _errors} =
#       OptionParser.parse(opts,
#         aliasses: [n: :name, o: :out, h: :help],
#         strict: [name: :string, out: :string, help: :boolean]
#       )

#     name = Keyword.get(parsed, :name)
#     out_dir = Keyword.get(parsed, :out)
#     help = Keyword.get(parsed, :help)

#     if help do
#       """
#       Generates an empty Nomenclator Module. The role of a nomenclator is 
#       to provide class names for all components.

#       Usage: 

#           mix buenavista.gen.nomenclator [options] 

#       Examples:

#           $ mix buenavista.gen.nomenclator --name bootstrap --out /tmp/path
#           $ mix buenavista.gen.nomenclator -n light -o /code/

#       Options:

#       -n, --name                 Gives name to the generated module and filename
#       -o, --out                  Output directory. Default lib/config/buenavista
#       -h, --help                 Show this help

#       """
#       |> IO.puts()
#     else
#       if is_nil(name) do
#         """
#         name is required for the hydrator. 

#         Check out all the options using the following command:

#             mix buenavista.gen.hydrator --help
#         """
#         |> Mix.raise()
#       end

#       generate_module(name, out_dir)
#     end

#     generate_module(name, out_dir)
#   end

#   defp generate_module(name, out_dir) do
#     module_components = BuenaVista.ComponentFinder.find_component_modules()

#     assigns = [
#       mod: Module.concat([BuenaVista, Nomenclator, camelize(name)]),
#       module_components: module_components
#     ]

#     out_dir =
#       if is_nil(out_dir) do
#         __ENV__.file
#         |> Path.dirname()
#         |> Path.join("../../nomenclator")
#       else
#         out_dir
#       end

#     filename = "#{underscore(name)}.ex"
#     file = Path.join(out_dir, filename)

#     create_file(file, config_template(assigns))
#   end

#   embed_template(:config, ~S/
#   defmodule <%= inspect @mod %> do
#     use BuenaVista.Nomenclator

#     <%= for {module, components} <- @module_components do %>
#     # ----------------------------------------
#     # <%= module |> Atom.to_string() |> String.replace("Elixir.", "") %>
#     # ----------------------------------------
#     <%= for {component, config} <- components do %>
#       <%= for classes <- Keyword.get(config, :classes) do %>
#         # def __class_name(:<%= component %>, :classes, :<%= Keyword.get(classes, :key) %>), do: ""<% end %>
#       <%= for {variant, v_config} <- Keyword.get(config, :variants) do %>
#         <%= for {option, _} <- Keyword.get(v_config, :options) do %>
#           # def __class_name(:<%= component %>, :<%= variant %>, :<%= option %>), do: ""<% end %>
#       <% end %>
#     <% end %>
#   <% end %>
#   end
#   /)
# end
