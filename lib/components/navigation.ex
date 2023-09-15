defmodule BuenaVista.Components.Navigation do
  use BuenaVista.Component

  variant :orientation, [:vertical, :horizontal], :vertical

  component navigation(assigns) do
    ~H"""
    <nav class={[@base_class, @variant_classes]}>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  attr :url, :string, required: true
  attr :nav, :atom, values: [:navigate, :patch, :href], required: true

  variant :state, [:default, :selected], :default

  slot :inner_block

  component navigation_item(assigns) do
    ~H"""
    <.link class={[@base_class, @variant_classes]} {[{@nav, @url}]}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
