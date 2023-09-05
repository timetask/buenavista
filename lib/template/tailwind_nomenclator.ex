defmodule BuenaVista.Template.TailwindNomenclator do
  @behaviour BuenaVista.Nomenclator
  @delegate BuenaVista.Template.DefaultNomenclator

  # ----------------------------------------
  # BuenaVista.Components.Modal
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # drawer
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:drawer, :classes, :base_class), do: "drawer"
  # def class_name(:drawer, :classes, :modal_content_class), do: "modal-content"
  # def class_name(:drawer, :classes, :close_btn_class), do: "close-btn"

  # def class_name(:drawer, :position, :top), do: "drawer-top"
  # def class_name(:drawer, :position, :right), do: "drawer-right"
  # def class_name(:drawer, :position, :bottom), do: "drawer-bottom"
  # def class_name(:drawer, :position, :left), do: "drawer-left"

  # def class_name(:drawer, :size, :sm), do: "drawer-sm"
  # def class_name(:drawer, :size, :md), do: "drawer-md"
  # def class_name(:drawer, :size, :lg), do: "drawer-lg"
  # def class_name(:drawer, :size, :full), do: "drawer-full"

  # - - - - - - - - - - - - - - - - - - - - 
  # modal
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:modal, :classes, :base_class), do: "modal"
  # def class_name(:modal, :classes, :content_class), do: "content"
  # def class_name(:modal, :classes, :close_class), do: "close"

  # def class_name(:modal, :position, :centered), do: "modal-centered"
  # def class_name(:modal, :position, :top), do: "modal-top"

  # def class_name(:modal, :size, :sm), do: "modal-sm"
  # def class_name(:modal, :size, :md), do: "modal-md"
  # def class_name(:modal, :size, :lg), do: "modal-lg"
  # def class_name(:modal, :size, :full), do: "modal-full"

  # ----------------------------------------
  # BuenaVista.Components.Layout
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # multi_column_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:multi_column_layout, :classes, :base_class), do: "multi-column-layout"

  # - - - - - - - - - - - - - - - - - - - - 
  # sidebar_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:sidebar_layout, :classes, :base_class), do: "sidebar-layout"
  # def class_name(:sidebar_layout, :classes, :sidebar_class), do: "sidebar"
  # def class_name(:sidebar_layout, :classes, :main_class), do: "main"

  # def class_name(:sidebar_layout, :position, :left), do: "sidebar-layout-left"
  # def class_name(:sidebar_layout, :position, :right), do: "sidebar-layout-right"

  # ----------------------------------------
  # BuenaVista.Components.Input
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # input
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:input, :classes, :base_class), do: "input"

  # def class_name(:input, :type, :text), do: "input-text"
  # def class_name(:input, :type, :number), do: "input-number"
  # def class_name(:input, :type, :email), do: "input-email"
  # def class_name(:input, :type, :password), do: "input-password"
  # def class_name(:input, :type, :radio), do: "input-radio"
  # def class_name(:input, :type, :checkbox), do: "input-checkbox"
  # def class_name(:input, :type, :hidden), do: "input-hidden"

  # - - - - - - - - - - - - - - - - - - - - 
  # input_group
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:input_group, :classes, :base_class), do: "input-group"

  # def class_name(:input_group, :layout, :vertical), do: "input-group-vertical"
  # def class_name(:input_group, :layout, :table), do: "input-group-table"
  # def class_name(:input_group, :layout, :stacked), do: "input-group-stacked"

  # def class_name(:input_group, :state, :default), do: "input-group-default"
  # def class_name(:input_group, :state, :success), do: "input-group-success"
  # def class_name(:input_group, :state, :danger), do: "input-group-danger"

  # - - - - - - - - - - - - - - - - - - - - 
  # label
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:label, :classes, :base_class), do: "label"

  # def class_name(:label, :state, :default), do: ""
  # def class_name(:label, :state, :success), do: "label-success"
  # def class_name(:label, :state, :danger), do: "label-danger"

  # ----------------------------------------
  # BuenaVista.Components.Form
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # form
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:form, :classes, :base_class), do: "form"

  # def class_name(:form, :display, :block), do: "form-block"
  # def class_name(:form, :display, :inline), do: "form-inline"

  # ----------------------------------------
  # BuenaVista.Components.Button
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # button
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:button, :classes, :base_class), do: "button"

  # def class_name(:button, :size, :xs), do: "button-xs"
  # def class_name(:button, :size, :sm), do: "button-sm"
  # def class_name(:button, :size, :md), do: "button-md"
  # def class_name(:button, :size, :lg), do: "button-lg"

  # def class_name(:button, :color, :nav), do: "button-nav"
  # def class_name(:button, :color, :ctrl), do: "button-ctrl"
  # def class_name(:button, :color, :primary), do: "button-primary"
  # def class_name(:button, :color, :success), do: "button-success"
  # def class_name(:button, :color, :danger), do: "button-danger"
  # def class_name(:button, :color, :warning), do: "button-warning"
  # def class_name(:button, :color, :info), do: "button-info"

  # def class_name(:button, :style, :filled), do: "button-filled"
  # def class_name(:button, :style, :outline), do: "button-outline"
  # def class_name(:button, :style, :soft), do: "button-soft"
  # def class_name(:button, :style, :link), do: "button-link"
  # def class_name(:button, :style, :transparent), do: "button-transparent"

  # def class_name(:button, :border, :none), do: ""
  # def class_name(:button, :border, :thin), do: "button-border-thin"
  # def class_name(:button, :border, :thick), do: "button-border-thick"

  defdelegate class_name(component, variant, option), to: @delegate
end
