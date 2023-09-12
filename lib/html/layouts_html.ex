defmodule BuenaVista.HTML.LayoutsHTML do
  use Phoenix.Component
  # import Phoenix.Controller,
  #   only: [get_csrf_token: 0, view_module: 1, view_template: 1]

  # import BuenaVista
  # import Phoenix.HTML
  # alias Phoenix.LiveView.JS

  embed_templates "layouts/*"
end
