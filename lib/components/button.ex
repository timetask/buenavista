defmodule BuenaVista.Components.Button do
  use BuenaVista.Component

  variant :size, [:xs, :sm, :md, :lg], :md
  variant :color, [:nav, :ctrl, :primary, :success, :danger, :warning, :info], :ctrl
  variant :style, [:filled, :outline, :soft, :link, :transparent], :filled
  variant :border, [:none, :thin, :thick], :thin

  attr :type, :string, default: "button", values: ["button", "submit"]
  attr :rest, :global

  slot :inner_block

  component button(assigns) do
    ~H"""
    <button class={[@base_class, @variant_classes]} type={@type} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
