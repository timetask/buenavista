locals_without_parens = [
  variant: 2,
  variant: 3,
  component: 1,
  component: 2,
  extra_classes: 1
]

[
  inputs: ["mix.exs", ".formatter.exs", "{lib,test}/**/*.{ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter, BuenaVista.CssFormatter],
  import_deps: [:phoenix],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  line_length: 120
]
