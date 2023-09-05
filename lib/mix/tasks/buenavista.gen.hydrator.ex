# defmodule Mix.Tasks.Buenavista.Gen.Hydrator do
#   use Mix.Task
#   require Logger

#   import Macro, only: [camelize: 1, underscore: 1]
#   import Mix.Generator

#   @shortdoc "Generates Hydrator Module (use `--help` for options)"
#   def run(opts) do
#     Mix.Task.run("app.config")

#     {parsed, _args, _errors} =
#       OptionParser.parse(opts,
#         aliasses: [n: :name, o: :out, h: :help],
#         strict: [name: :string, out: :string, help: :boolean]
#       )

#     help = Keyword.get(parsed, :help)
#     name = Keyword.get(parsed, :name)
#     out_dir = Keyword.get(parsed, :out)

#     if help do
#       """
#       Generates an empty Hydrator Module. The role of a hydrator is to provide the css 
#       content for all components.

#       Usage: 

#           mix buenavista.gen.hydrator [options] 

#       Examples:

#           $ mix buenavista.gen.hydrator --name tailwind --out /tmp/path
#           $ mix buenavista.gen.hydrator -n dark_theme -o /code/

#       Options:

#       -n, --name                 Name used to generate the file and module name
#       -o, --out                  Output directory. Default: lib/hydrators
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
#   end

#   defp generate_module(name, out_dir) do
#     module_components = BuenaVista.ComponentFinder.find_component_modules()

#     assigns = [
#       mod: Module.concat([BuenaVista, Hydrator, camelize(name)]),
#       module_components: module_components
#     ]

#     out_dir =
#       if is_nil(out_dir) do
#         __ENV__.file
#         |> Path.dirname()
#         |> Path.join("../../hydrators")
#       else
#         out_dir
#       end

#     filename = "#{underscore(name)}.ex"
#     file = Path.join(out_dir, filename)

#     create_file(file, hydrator_template(assigns))
#   end

#   embed_template(:hydrator, ~S/
#   defmodule <%= inspect @mod %> do
#     use BuenaVista.Hydrator

#     # def get_variables(), do: [] 

#     <%= for {module, components} <- @module_components do %>
#       # ----------------------------------------
#       # <%= module |> Atom.to_string() |> String.replace("Elixir.", "") %>
#       # ----------------------------------------
#       <%= for {_, component} <- components do %>
#         <%= for {class_key, _} <- component.classes do %>
#           # def css(:<%= component.name %>, :classes, :<%= class_key %>), do: ""<% end %>
#         <%= for variant <- component.variants do %>
#           <%= for {option_key, _} <- variant.options do %>
#             # def css(:<%= component.name %>, :<%= variant.name %>, :<%= option_key %>), do: ""<% end %>
#         <% end %>
#       <% end %>
#     <% end %>
#   end
#   /)
# end
