defmodule BuenaVista.Components.Input do
  use BuenaVista.Component

  import BuenaVista.Components.ErrorHelpers

  alias Phoenix.HTML.FormField

  # ----------------------------------------
  # label
  # ----------------------------------------
  variant :state, [:default, :success, :danger], :default

  attr :field, FormField, required: true
  attr :label, :string, default: nil

  slot :inner_block

  component label(assigns) do
    ~H"""
    <label for={@field.id} class={[@base_class, @variant_classes]}>
      <%= if is_nil(@label) do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
    </label>
    """
  end

  # ----------------------------------------
  # input_group
  # ----------------------------------------
  variant :layout, [:vertical, :table, :stacked], :vertical
  variant :state, [:default, :success, :danger], :default

  attr :id, :string, default: nil
  attr :field, FormField
  attr :label, :string, default: "Input label"

  slot :inner_block, required: true

  component input_group(assigns) do
    ~H"""
    <div id={@id} class={[@base_class, @variant_classes]} phx-feedback-for={@field.name}>
       <span class="input-group-label">
        <.label field={@field} label={@label} state={@state}/>
        <i :if={@state == :success} class="bx bx-check" />
        <p :if={@state == :error}>
          <span :for={error <- @field.errors} class="input-error phx-no-feedback:hidden">
            <%= error_text(error) %>
            <i class="bx bxs-x-circle text-normal" />
          </span>
        </p>
      </span>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ----------------------------------------
  # input
  # ----------------------------------------
  variant :type, [:text, :number, :email, :password, :radio, :checkbox, :hidden], :text

  attr :field, FormField, required: true
  attr :disabled, :boolean, default: false
  attr :autocomplete, :string, default: "off"
  attr :rest, :global

  component input(assigns) do
    ~H"""
    <input
      type={@type}
      name={@field.name}
      id={@field.id}
      value={@field.value}
      class={[@base_class, @variant_classes]}
      disabled={@disabled}
      autocomplete={@autocomplete}
      {@rest}
    />
    """
  end
end
