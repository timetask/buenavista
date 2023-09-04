defmodule BuenaVista.Components.Form do
  use BuenaVista.Component

  variant :display, [:block, :inline], :block

  slot :inner_block

  component form(assigns) do
    ~H"""
    <form class={[@base_class, @variant_classes]}>
      <%= render_slot(@inner_block) %>
    </form>
    """
  end
end
