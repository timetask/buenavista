defmodule BuenaVista.Components.Typography do
  use BuenaVista.Component

  attr :tag, :atom, values: [:h1, :h2, :h3, :h4, :h5, :h6], default: :h3
  variant :decoration, [:none, :accent, :spaced_uppcase], :none
  variant :size, [:sm, :md, :lg, :xl, :xxl], :lg

  classes [:tag_class, :inline_class, :actions_class]

  slot :inner_block

  slot :secondary do
    attr :inline, :boolean
  end

  slot :actions

  component heading(assigns) do
    ~H"""
    <div class={[@base_class, @variant_classes]}>
      <.dynamic_tag name={Atom.to_string(@tag)} class={@tag_class}>
        <%= render_slot(@inner_block) %>
        <span :if={@secondary} class={@inline_class}><%= render_slot(@secondary) %></span>
      </.dynamic_tag>
      <div :if={@actions} class={@actions_class}><%= render_slot(@actions) %></div>
    </div>
    """
  end
end
