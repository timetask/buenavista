defmodule BuenaVista.Template.DefaultHydrator do
  use BuenaVista.Hydrator, parent: BuenaVista.Template.EmptyHydrator

  variable :navigation_horizontal_gap, "0"
  variable :navigation_horizontal_padding, "0"
  variable :navigation_item_padding, "10px 15px"
  variable :navigation_vertical_gap, "0"
  variable :navigation_vertical_padding, "0"

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Navigation
  # ---------------------------------------------------------------------

  # navigation
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  style [:navigation, :classes, :base_class], ~CSS"""
    display: flex;
  """

  style [:navigation, :classes, :list_item_class], ~CSS"""
    padding: <%= @navigation_item_padding %>;
  """

  style [:navigation, :orientation, :vertical], ~CSS"""
    gap: <%= @navigation_vertical_gap %>;
    padding: <%= @navigation_vertical_padding %>;
    flex-direction: column;
  """

  style [:navigation, :orientation, :horizontal], ~CSS"""
    gap: <%= @navigation_horizontal_gap %>;
    padding: <%= @navigation_horizontal_padding %>;
    flex-direction: row;
  """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Modal
  # ---------------------------------------------------------------------

  # drawer
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:drawer, :classes, :base_class], ~CSS"""
  # """
  # style [:drawer, :classes, :modal_content_class], ~CSS"""
  # """
  # style [:drawer, :classes, :close_btn_class], ~CSS"""
  # """

  # style [:drawer, :position, :top], ~CSS"""
  # """
  # style [:drawer, :position, :right], ~CSS"""
  # """
  # style [:drawer, :position, :bottom], ~CSS"""
  # """
  # style [:drawer, :position, :left], ~CSS"""
  # """

  # style [:drawer, :size, :sm], ~CSS"""
  # """
  # style [:drawer, :size, :md], ~CSS"""
  # """
  # style [:drawer, :size, :lg], ~CSS"""
  # """
  # style [:drawer, :size, :full], ~CSS"""
  # """

  # modal
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:modal, :classes, :base_class], ~CSS"""
  # """
  # style [:modal, :classes, :content_class], ~CSS"""
  # """
  # style [:modal, :classes, :close_class], ~CSS"""
  # """

  # style [:modal, :position, :centered], ~CSS"""
  # """
  # style [:modal, :position, :top], ~CSS"""
  # """

  # style [:modal, :size, :sm], ~CSS"""
  # """
  # style [:modal, :size, :md], ~CSS"""
  # """
  # style [:modal, :size, :lg], ~CSS"""
  # """
  # style [:modal, :size, :full], ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Layout
  # ---------------------------------------------------------------------

  # multi_column_layout
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:multi_column_layout, :classes, :base_class], ~CSS"""
  # """

  # sidebar_layout
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  variable :sidebar_width, "20rem"

  style [:sidebar_layout, :classes, :base_class], ~CSS"""
    flex-wrap: wrap;
    display: flex;
  """

  style [:sidebar_layout, :classes, :sidebar_class], ~CSS"""
    flex-grow: 1;
    flex-basis: <%= @sidebar_width %>;
  """

  style [:sidebar_layout, :classes, :main_class], ~CSS"""
    min-inline-size: 50%;
    flex-grow: 999;
    flex-basis: 0;
  """

  # style [:sidebar_layout, :position, :left], ~CSS"""
  # """
  # style [:sidebar_layout, :position, :right], ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Input
  # ---------------------------------------------------------------------

  # input
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:input, :classes, :base_class], ~CSS"""
  # """

  # style [:input, :type, :text], ~CSS"""
  # """
  # style [:input, :type, :number], ~CSS"""
  # """
  # style [:input, :type, :email], ~CSS"""
  # """
  # style [:input, :type, :password], ~CSS"""
  # """
  # style [:input, :type, :radio], ~CSS"""
  # """
  # style [:input, :type, :checkbox], ~CSS"""
  # """
  # style [:input, :type, :hidden], ~CSS"""
  # """

  # input_group
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:input_group, :classes, :base_class], ~CSS"""
  # """

  # style [:input_group, :layout, :vertical], ~CSS"""
  # """
  # style [:input_group, :layout, :table], ~CSS"""
  # """
  # style [:input_group, :layout, :stacked], ~CSS"""
  # """

  # style [:input_group, :state, :default], ~CSS"""
  # """
  # style [:input_group, :state, :success], ~CSS"""
  # """
  # style [:input_group, :state, :danger], ~CSS"""
  # """

  # label
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:label, :classes, :base_class], ~CSS"""
  # """

  # style [:label, :state, :default], ~CSS"""
  # """
  # style [:label, :state, :success], ~CSS"""
  # """
  # style [:label, :state, :danger], ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Form
  # ---------------------------------------------------------------------

  # form
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:form, :classes, :base_class], ~CSS"""
  # """

  # style [:form, :display, :block], ~CSS"""
  # """
  # style [:form, :display, :inline], ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Button
  # ---------------------------------------------------------------------

  # button
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:button, :classes, :base_class], ~CSS"""
  # """

  # style [:button, :size, :xs], ~CSS"""
  # """
  # style [:button, :size, :sm], ~CSS"""
  # """
  # style [:button, :size, :md], ~CSS"""
  # """
  # style [:button, :size, :lg], ~CSS"""
  # """

  # style [:button, :color, :nav], ~CSS"""
  # """
  # style [:button, :color, :ctrl], ~CSS"""
  # """
  # style [:button, :color, :primary], ~CSS"""
  # """
  # style [:button, :color, :success], ~CSS"""
  # """
  # style [:button, :color, :danger], ~CSS"""
  # """
  # style [:button, :color, :warning], ~CSS"""
  # """
  # style [:button, :color, :info], ~CSS"""
  # """

  # style [:button, :style, :filled], ~CSS"""
  # """
  # style [:button, :style, :outline], ~CSS"""
  # """
  # style [:button, :style, :soft], ~CSS"""
  # """
  # style [:button, :style, :link], ~CSS"""
  # """
  # style [:button, :style, :transparent], ~CSS"""
  # """

  # style [:button, :border, :none], ~CSS"""
  # """
  # style [:button, :border, :thin], ~CSS"""
  # """
  # style [:button, :border, :thick], ~CSS"""
  # """
end
