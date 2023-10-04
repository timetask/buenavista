locals_without_parens = [
  var: 2,
  style: 2,
  variant: 3,
  component: 1,
  component: 2,
  classes: 1,
  field: 1,
  field: 2,
  galeria_routes: 2,
  galeria_routes: 1
]

[
  inputs: ["mix.exs", ".formatter.exs", "{lib,test}/**/*.{ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter, BuenaVista.CssFormatter],
  import_deps: [:phoenix],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  line_length: 120
]
