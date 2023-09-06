defmodule BuenaVista.Template.CssHydrator do
  use BuenaVista.Hydrator
  @delegate BuenaVista.Template.EmptyHydrator

  # defp variables(), do: [] 

  # ----------------------------------------
  # BuenaVista.Components.Modal
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # drawer
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:drawer, :classes, :base_class), do: ~S||
  # def css(:drawer, :classes, :modal_content_class), do: ~S||
  # def css(:drawer, :classes, :close_btn_class), do: ~S||

  # def css(:drawer, :position, :top), do: ~S||
  # def css(:drawer, :position, :right), do: ~S||
  # def css(:drawer, :position, :bottom), do: ~S||
  # def css(:drawer, :position, :left), do: ~S||

  # def css(:drawer, :size, :sm), do: ~S||
  # def css(:drawer, :size, :md), do: ~S||
  # def css(:drawer, :size, :lg), do: ~S||
  # def css(:drawer, :size, :full), do: ~S||

  # - - - - - - - - - - - - - - - - - - - - 
  # modal
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:modal, :classes, :base_class), do: ~S||
  # def css(:modal, :classes, :content_class), do: ~S||
  # def css(:modal, :classes, :close_class), do: ~S||

  # def css(:modal, :position, :centered), do: ~S||
  # def css(:modal, :position, :top), do: ~S||

  # def css(:modal, :size, :sm), do: ~S||
  # def css(:modal, :size, :md), do: ~S||
  # def css(:modal, :size, :lg), do: ~S||
  # def css(:modal, :size, :full), do: ~S||

  # ----------------------------------------
  # BuenaVista.Components.Layout
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # multi_column_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:multi_column_layout, :classes, :base_class), do: ~S||

  # - - - - - - - - - - - - - - - - - - - - 
  # sidebar_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:sidebar_layout, :classes, :base_class), do: ~S||
  # def css(:sidebar_layout, :classes, :sidebar_class), do: ~S||
  # def css(:sidebar_layout, :classes, :main_class), do: ~S||

  # def css(:sidebar_layout, :position, :left), do: ~S||
  # def css(:sidebar_layout, :position, :right), do: ~S||

  # ----------------------------------------
  # BuenaVista.Components.Input
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # input
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:input, :classes, :base_class), do: ~S||

  # def css(:input, :type, :text), do: ~S||
  # def css(:input, :type, :number), do: ~S||
  # def css(:input, :type, :email), do: ~S||
  # def css(:input, :type, :password), do: ~S||
  # def css(:input, :type, :radio), do: ~S||
  # def css(:input, :type, :checkbox), do: ~S||
  # def css(:input, :type, :hidden), do: ~S||

  # - - - - - - - - - - - - - - - - - - - - 
  # input_group
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:input_group, :classes, :base_class), do: ~S||

  # def css(:input_group, :layout, :vertical), do: ~S||
  # def css(:input_group, :layout, :table), do: ~S||
  # def css(:input_group, :layout, :stacked), do: ~S||

  # def css(:input_group, :state, :default), do: ~S||
  # def css(:input_group, :state, :success), do: ~S||
  # def css(:input_group, :state, :danger), do: ~S||

  # - - - - - - - - - - - - - - - - - - - - 
  # label
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:label, :classes, :base_class), do: ~S||

  # def css(:label, :state, :default), do: ~S||
  # def css(:label, :state, :success), do: ~S||
  # def css(:label, :state, :danger), do: ~S||

  # ----------------------------------------
  # BuenaVista.Components.Form
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # form
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:form, :classes, :base_class), do: ~S||

  # def css(:form, :display, :block), do: ~S||
  # def css(:form, :display, :inline), do: ~S||

  # ----------------------------------------
  # BuenaVista.Components.Button
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # button
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:button, :classes, :base_class), do: ~S||

  # def css(:button, :size, :xs), do: ~S||
  # def css(:button, :size, :sm), do: ~S||
  # def css(:button, :size, :md), do: ~S||
  # def css(:button, :size, :lg), do: ~S||

  # def css(:button, :color, :nav), do: ~S||
  # def css(:button, :color, :ctrl), do: ~S||
  # def css(:button, :color, :primary), do: ~S||
  # def css(:button, :color, :success), do: ~S||
  # def css(:button, :color, :danger), do: ~S||
  # def css(:button, :color, :warning), do: ~S||
  # def css(:button, :color, :info), do: ~S||

  # def css(:button, :style, :filled), do: ~S||
  # def css(:button, :style, :outline), do: ~S||
  # def css(:button, :style, :soft), do: ~S||
  # def css(:button, :style, :link), do: ~S||
  # def css(:button, :style, :transparent), do: ~S||

  # def css(:button, :border, :none), do: ~S||
  # def css(:button, :border, :thin), do: ~S||
  # def css(:button, :border, :thick), do: ~S||

  defdelegate css(component, variant, option), to: @delegate
end
