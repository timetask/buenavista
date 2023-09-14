defmodule BuenaVista.Components.Navigation do
  use BuenaVista.Component

  defmodule NavItem do
    use TypedStruct

    typedstruct enforce: true do
      field :url, String.t()
      field :nav, atom()
      field :item, any()
    end
  end

  variant :orientation, [:vertical, :horizontal], :vertical

  classes [:list_item_class]

  attr :items, :list, default: []

  slot :link do
    attr :url, :string, required: true
    attr :nav, :atom, values: [:navigate, :patch, :href], required: true
  end

  component navigation(assigns) do
    ~H"""
    <nav class={[@base_class, @variant_classes]}>
      <.link :for={item <- @items} class={@list_item_class} {[{item.nav, item.url}]}>
        <%= render_slot(@link, item.item) %>
      </.link>
    </nav>
    """
  end
end
