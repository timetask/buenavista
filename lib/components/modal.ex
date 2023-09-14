defmodule BuenaVista.Components.Modal do
  use BuenaVista.Component

  variant :position, [:centered, :top], :centered
  variant :size, [:sm, :md, :lg, :full], :md

  attr :id, :string, required: true

  classes [:content_class, :close_class]

  component modal(assigns) do
    ~H"""
    <div id={@id} class={[@base_class, @variant_classes]}>
      <div class={@content_class}>
        <a href="#" class={@close_class} />
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  variant :position, [:top, :right, :bottom, :left], :right
  variant :size, [:sm, :md, :lg, :full], :md

  attr :id, :string, required: true

  classes [:modal_content_class, :close_btn_class]

  component drawer(assigns) do
    ~H"""
    <div id={@id} class={[@base_class, @variant_classes]}>
      <div class={@content_class}>
        <a href="#" class={@close_class} />
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
