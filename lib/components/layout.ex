defmodule BuenaVista.Components.Layout do
  use BuenaVista.Component

  # component stacked_layout(assigns) do
  #   ~H"""
  #   <div></div>
  #   """
  # end

  variant :position, [:left, :right], :left

  slot :sidebar, required: true
  slot :main, required: true

  classes [:sidebar_class, :main_class]

  component sidebar_layout(assigns) do
    ~H"""
    <div class={[@base_class, @variant_classes]}>
      <sidebar class={@sidebar_class}>
        <%= render_slot(@sidebar) %>
      </sidebar>
      <main class={@main_class}>
        <%= render_slot(@main) %>
      </main>
    </div>
    """
  end

  component multi_column_layout(assigns) do
    ~H"""

    """
  end
end
