defmodule BuenaVista.Templates.TailwindInlineNomenclator do
  @behaviour BuenaVista.Nomenclator

  # ----------------------------------------
  # BuenaVista.Components.Modal
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # drawer
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:drawer, :classes, :base_class), do: "
  # def class_name(:drawer, :classes, :modal_content_class), do: "
  # def class_name(:drawer, :classes, :close_btn_class), do: "

  # def class_name(:drawer, :position, :top), do: "
  # def class_name(:drawer, :position, :right), do: "
  # def class_name(:drawer, :position, :bottom), do: "
  # def class_name(:drawer, :position, :left), do: "

  # def class_name(:drawer, :size, :sm), do: "
  # def class_name(:drawer, :size, :md), do: "
  # def class_name(:drawer, :size, :lg), do: "
  # def class_name(:drawer, :size, :full), do: "

  # - - - - - - - - - - - - - - - - - - - - 
  # modal
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:modal, :classes, :base_class), do: "
  # def class_name(:modal, :classes, :content_class), do: "
  # def class_name(:modal, :classes, :close_class), do: "

  # def class_name(:modal, :position, :centered), do: "
  # def class_name(:modal, :position, :top), do: "

  # def class_name(:modal, :size, :sm), do: "
  # def class_name(:modal, :size, :md), do: "
  # def class_name(:modal, :size, :lg), do: "
  # def class_name(:modal, :size, :full), do: "

  # ----------------------------------------
  # BuenaVista.Components.Layout
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # multi_column_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:multi_column_layout, :classes, :base_class), do: "

  # - - - - - - - - - - - - - - - - - - - - 
  # sidebar_layout
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:sidebar_layout, :classes, :base_class), do: "
  # def class_name(:sidebar_layout, :classes, :sidebar_class), do: "
  # def class_name(:sidebar_layout, :classes, :main_class), do: "

  # def class_name(:sidebar_layout, :position, :left), do: "
  # def class_name(:sidebar_layout, :position, :right), do: "

  # ----------------------------------------
  # BuenaVista.Components.Input
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # input
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:input, :classes, :base_class), do: "

  # def class_name(:input, :type, :text), do: "
  # def class_name(:input, :type, :number), do: "
  # def class_name(:input, :type, :email), do: "
  # def class_name(:input, :type, :password), do: "
  # def class_name(:input, :type, :radio), do: "
  # def class_name(:input, :type, :checkbox), do: "
  # def class_name(:input, :type, :hidden), do: "

  # - - - - - - - - - - - - - - - - - - - - 
  # input_group
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:input_group, :classes, :base_class), do: "

  # def class_name(:input_group, :layout, :vertical), do: "
  # def class_name(:input_group, :layout, :table), do: "
  # def class_name(:input_group, :layout, :stacked), do: "

  # def class_name(:input_group, :state, :default), do: "
  # def class_name(:input_group, :state, :success), do: "
  # def class_name(:input_group, :state, :danger), do: "

  # - - - - - - - - - - - - - - - - - - - - 
  # label
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:label, :classes, :base_class), do: "

  # def class_name(:label, :state, :default), do: "
  # def class_name(:label, :state, :success), do: "
  # def class_name(:label, :state, :danger), do: "

  # ----------------------------------------
  # BuenaVista.Components.Form
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # form
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:form, :classes, :base_class), do: "

  # def class_name(:form, :display, :block), do: "
  # def class_name(:form, :display, :inline), do: "

  # ----------------------------------------
  # BuenaVista.Components.Button
  # ----------------------------------------

  # - - - - - - - - - - - - - - - - - - - - 
  # button
  # - - - - - - - - - - - - - - - - - - - - 

  # def class_name(:button, :classes, :base_class), do: "

  # def class_name(:button, :size, :xs), do: "
  # def class_name(:button, :size, :sm), do: "
  # def class_name(:button, :size, :md), do: "
  # def class_name(:button, :size, :lg), do: "

  # def class_name(:button, :color, :nav), do: "
  # def class_name(:button, :color, :ctrl), do: "
  # def class_name(:button, :color, :primary), do: "
  # def class_name(:button, :color, :success), do: "
  # def class_name(:button, :color, :danger), do: "
  # def class_name(:button, :color, :warning), do: "
  # def class_name(:button, :color, :info), do: "

  # def class_name(:button, :style, :filled), do: "
  # def class_name(:button, :style, :outline), do: "
  # def class_name(:button, :style, :soft), do: "
  # def class_name(:button, :style, :link), do: "
  # def class_name(:button, :style, :transparent), do: "

  # def class_name(:button, :border, :none), do: "
  # def class_name(:button, :border, :thin), do: "
  # def class_name(:button, :border, :thick), do: "
end
