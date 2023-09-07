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

  # def css(:drawer, :classes, :base_class), do: ~CSS||
  # def css(:drawer, :classes, :modal_content_class), do: ~CSS||
  # def css(:drawer, :classes, :close_btn_class), do: ~CSS||

  # def css(:drawer, :position, :top), do: ~CSS||
  # def css(:drawer, :position, :right), do: ~CSS||
  # def css(:drawer, :position, :bottom), do: ~CSS||
  # def css(:drawer, :position, :left), do: ~CSS||

  # def css(:drawer, :size, :sm), do: ~CSS||
  # def css(:drawer, :size, :md), do: ~CSS||
  # def css(:drawer, :size, :lg), do: ~CSS||
  # def css(:drawer, :size, :full), do: ~CSS||

  # - - - - - - - - - - - - - - - - - - - - 
  # modal
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:modal, :classes, :base_class), do: ~CSS||
  # def css(:modal, :classes, :content_class), do: ~CSS||
  # def css(:modal, :classes, :close_class), do: ~CSS||

  # def css(:modal, :position, :centered), do: ~CSS||
  # def css(:modal, :position, :top), do: ~CSS||

  # def css(:modal, :size, :sm), do: ~CSS||
  # def css(:modal, :size, :md), do: ~CSS||
  # def css(:modal, :size, :lg), do: ~CSS||
  # def css(:modal, :size, :full), do: ~CSS||

  # ----------------------------------------
  # BuenaVista.Components.Layout
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # multi_column_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:multi_column_layout, :classes, :base_class), do: ~CSS||

  # - - - - - - - - - - - - - - - - - - - - 
  # sidebar_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:sidebar_layout, :classes, :base_class), do: ~CSS||
  # def css(:sidebar_layout, :classes, :sidebar_class), do: ~CSS||
  # def css(:sidebar_layout, :classes, :main_class), do: ~CSS||

  # def css(:sidebar_layout, :position, :left), do: ~CSS||
  # def css(:sidebar_layout, :position, :right), do: ~CSS||

  # ----------------------------------------
  # BuenaVista.Components.Input
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # input
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:input, :classes, :base_class), do: ~CSS||

  # def css(:input, :type, :text), do: ~CSS||
  # def css(:input, :type, :number), do: ~CSS||
  # def css(:input, :type, :email), do: ~CSS||
  # def css(:input, :type, :password), do: ~CSS||
  # def css(:input, :type, :radio), do: ~CSS||
  # def css(:input, :type, :checkbox), do: ~CSS||
  # def css(:input, :type, :hidden), do: ~CSS||

  # - - - - - - - - - - - - - - - - - - - - 
  # input_group
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:input_group, :classes, :base_class), do: ~CSS||

  # def css(:input_group, :layout, :vertical), do: ~CSS||
  # def css(:input_group, :layout, :table), do: ~CSS||
  # def css(:input_group, :layout, :stacked), do: ~CSS||

  # def css(:input_group, :state, :default), do: ~CSS||
  # def css(:input_group, :state, :success), do: ~CSS||
  # def css(:input_group, :state, :danger), do: ~CSS||

  # - - - - - - - - - - - - - - - - - - - - 
  # label
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:label, :classes, :base_class), do: ~CSS||

  # def css(:label, :state, :default), do: ~CSS||
  # def css(:label, :state, :success), do: ~CSS||
  # def css(:label, :state, :danger), do: ~CSS||

  # ----------------------------------------
  # BuenaVista.Components.Form
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # form
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:form, :classes, :base_class), do: ~CSS||

  # def css(:form, :display, :block), do: ~CSS||
  # def css(:form, :display, :inline), do: ~CSS||

  # ----------------------------------------
  # BuenaVista.Components.Button
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # button
  # - - - - - - - - - - - - - - - - - - - - 

  # def css(:button, :classes, :base_class), do: ~CSS||

  # def css(:button, :size, :xs), do: ~CSS||
  # def css(:button, :size, :sm), do: ~CSS||
  # def css(:button, :size, :md), do: ~CSS||
  # def css(:button, :size, :lg), do: ~CSS||

  # def css(:button, :color, :nav), do: ~CSS||
  # def css(:button, :color, :ctrl), do: ~CSS||
  # def css(:button, :color, :primary), do: ~CSS||
  # def css(:button, :color, :success), do: ~CSS||
  # def css(:button, :color, :danger), do: ~CSS||
  # def css(:button, :color, :warning), do: ~CSS||
  # def css(:button, :color, :info), do: ~CSS||

  # def css(:button, :style, :filled), do: ~CSS||
  # def css(:button, :style, :outline), do: ~CSS||
  # def css(:button, :style, :soft), do: ~CSS||
  # def css(:button, :style, :link), do: ~CSS||
  # def css(:button, :style, :transparent), do: ~CSS||

  # def css(:button, :border, :none), do: ~CSS||
  # def css(:button, :border, :thin), do: ~CSS||
  # def css(:button, :border, :thick), do: ~CSS||

  defdelegate css(component, variant, option), to: @delegate
end
