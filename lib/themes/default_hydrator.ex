defmodule BuenaVista.Themes.DefaultHydrator do
  use BuenaVista.Hydrator,
    nomenclator: BuenaVista.Themes.DefaultNomenclator,
    parent: BuenaVista.Themes.EmptyHydrator

  import BuenaVista.Constants.TailwindColors
  import BuenaVista.Constants.TailwindSizes

  # ---------------------------------------------------------------------
  # Variables
  # ---------------------------------------------------------------------

  # app
  var :app_gutter, ~VAR[size(2)]

  # color
  var :color_title, ~VAR[color(:gray, 900)]
  var :color_text, ~VAR[color(:gray, 600)]
  var :color_text_subtle, ~VAR[color(:gray, 400)]

  # sidebar
  var :sidebar_width, ~VAR[size(80)]

  # font
  var :font_xs, ~VAR[size(2)]
  var :font_sm, ~VAR[size(3)]
  var :font_md, ~VAR[size(4)]
  var :font_lg, ~VAR[size(5)]
  var :font_xl, ~VAR[size(6)]
  var :font_xxl, ~VAR[size(7)]

  # gap
  var :gap_xs, ~VAR[size(0.5)]
  var :gap_sm, ~VAR[size(1)]
  var :gap_md, ~VAR[size(2)]
  var :gap_lg, ~VAR[size(3)]
  var :gap_xl, ~VAR[size(4)]

  # size
  var :size_xs, ~VAR[size(0.5)]
  var :size_sm, ~VAR[size(1)]
  var :size_md, ~VAR[size(2)]
  var :size_lg, ~VAR[size(3)]
  var :size_xl, ~VAR[size(4)]

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Typography                             heading
  # ---------------------------------------------------------------------

  style :heading, :base_class, ~CSS"""
    color: $color_text;
    flex-direction: column;
    align-items: flex-start;
    display: flex;
  """

  style :heading, :title_tag_class, ~CSS"""
    font-weight: bold;
  """

  style :heading, :inline_class, ~CSS"""
    font-weight: normal;
    font-size: 70%;
  """

  style :heading, :actions_class, ~CSS"""
    color: red;
  """

  # style :heading, :decoration, :accent, ~CSS"""
  # """
  style :heading, :decoration, :spaced_uppcase, ~CSS"""
    color: $color_text_subtle;
    text-transform: uppercase;
    letter-spacing: 0.2rem;

    .$heading__title_tag_class {
      font-weight: 300;
    }
  """

  style :heading, :size, :sm, ~CSS"""
    font-size: $font_sm;
  """

  style :heading, :size, :md, ~CSS"""
    font-size: $font_md;
  """

  style :heading, :size, :lg, ~CSS"""
    font-size: $font_lg;
  """

  style :heading, :size, :xl, ~CSS"""
    font-size: $font_xl;
  """

  style :heading, :size, :xxl, ~CSS"""
    font-size: $font_xxl;
  """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Navigation                     navigation_item
  # ---------------------------------------------------------------------

  # style :navigation_item, :base_class, ~CSS"""
  # """

  # style :navigation_item, :state, :selected, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Navigation                          navigation
  # ---------------------------------------------------------------------

  style :navigation, :base_class, ~CSS"""
    display: flex;
  """

  style :navigation, :orientation, :vertical, ~CSS"""
    flex-direction: column;
  """

  style :navigation, :orientation, :horizontal, ~CSS"""
    gap: $gap_sm;
    flex-direction: row;
  """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Modal                                   drawer
  # ---------------------------------------------------------------------

  # style :drawer, :base_class, ~CSS"""
  # """
  # style :drawer, :modal_content_class, ~CSS"""
  # """
  # style :drawer, :close_btn_class, ~CSS"""
  # """

  # style :drawer, :position, :top, ~CSS"""
  # """
  # style :drawer, :position, :right, ~CSS"""
  # """
  # style :drawer, :position, :bottom, ~CSS"""
  # """
  # style :drawer, :position, :left, ~CSS"""
  # """

  # style :drawer, :size, :sm, ~CSS"""
  # """
  # style :drawer, :size, :md, ~CSS"""
  # """
  # style :drawer, :size, :lg, ~CSS"""
  # """
  # style :drawer, :size, :full, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Modal                                    modal
  # ---------------------------------------------------------------------

  # style :modal, :base_class, ~CSS"""
  # """
  # style :modal, :content_class, ~CSS"""
  # """
  # style :modal, :close_class, ~CSS"""
  # """

  # style :modal, :position, :centered, ~CSS"""
  # """
  # style :modal, :position, :top, ~CSS"""
  # """

  # style :modal, :size, :sm, ~CSS"""
  # """
  # style :modal, :size, :md, ~CSS"""
  # """
  # style :modal, :size, :lg, ~CSS"""
  # """
  # style :modal, :size, :full, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Layout                     multi_column_layout
  # ---------------------------------------------------------------------

  # style :multi_column_layout, :base_class, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Layout                          sidebar_layout
  # ---------------------------------------------------------------------

  style :sidebar_layout, :base_class, ~CSS"""
    display: flex;
  """

  style :sidebar_layout, :sidebar_class, ~CSS"""
    width: $sidebar_width;
    flex-grow: 1;
  """

  style :sidebar_layout, :main_class, ~CSS"""
    min-inline-size: 50%;
    flex-grow: 999;
    flex-basis: 0;
  """

  style :sidebar_layout, :position, :right, ~CSS"""
    flex-direction: row-reversed;
  """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Input                                    input
  # ---------------------------------------------------------------------

  # style :input, :base_class, ~CSS"""
  # """

  # style :input, :type, :text, ~CSS"""
  # """
  # style :input, :type, :number, ~CSS"""
  # """
  # style :input, :type, :email, ~CSS"""
  # """
  # style :input, :type, :password, ~CSS"""
  # """
  # style :input, :type, :radio, ~CSS"""
  # """
  # style :input, :type, :checkbox, ~CSS"""
  # """
  # style :input, :type, :hidden, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Input                              input_group
  # ---------------------------------------------------------------------

  # style :input_group, :base_class, ~CSS"""
  # """

  # style :input_group, :layout, :vertical, ~CSS"""
  # """
  # style :input_group, :layout, :table, ~CSS"""
  # """
  # style :input_group, :layout, :stacked, ~CSS"""
  # """

  # style :input_group, :state, :success, ~CSS"""
  # """
  # style :input_group, :state, :danger, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Input                                    label
  # ---------------------------------------------------------------------

  # style :label, :base_class, ~CSS"""
  # """

  # style :label, :state, :success, ~CSS"""
  # """
  # style :label, :state, :danger, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Form                                      form
  # ---------------------------------------------------------------------

  # style :form, :base_class, ~CSS"""
  # """

  # style :form, :display, :block, ~CSS"""
  # """
  # style :form, :display, :inline, ~CSS"""
  # """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Button                                  button
  # ---------------------------------------------------------------------

  # style :button, :base_class, ~CSS"""
  # """

  # style :button, :size, :xs, ~CSS"""
  # """
  # style :button, :size, :sm, ~CSS"""
  # """
  # style :button, :size, :md, ~CSS"""
  # """
  # style :button, :size, :lg, ~CSS"""
  # """

  # style :button, :color, :nav, ~CSS"""
  # """
  # style :button, :color, :ctrl, ~CSS"""
  # """
  # style :button, :color, :primary, ~CSS"""
  # """
  # style :button, :color, :success, ~CSS"""
  # """
  # style :button, :color, :danger, ~CSS"""
  # """
  # style :button, :color, :warning, ~CSS"""
  # """
  # style :button, :color, :info, ~CSS"""
  # """

  # style :button, :style, :filled, ~CSS"""
  # """
  # style :button, :style, :outline, ~CSS"""
  # """
  # style :button, :style, :soft, ~CSS"""
  # """
  # style :button, :style, :link, ~CSS"""
  # """
  # style :button, :style, :transparent, ~CSS"""
  # """

  # style :button, :border, :thin, ~CSS"""
  # """
  # style :button, :border, :thick, ~CSS"""
  # """
end
