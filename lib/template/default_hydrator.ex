defmodule BuenaVista.Template.DefaultHydrator do
  use BuenaVista.Hydrator,
    nomenclator: BuenaVista.Template.DefaultNomenclator,
    parent: BuenaVista.Template.EmptyHydrator

  import BuenaVista.Constants.DefaultColors
  import BuenaVista.Constants.DefaultSizes

  # color
  variable :color_text, ~FUNC[color(:red, 500)]
  variable :color_text_subtle, "#78716c"
  variable :color_title, "#292524"

  # sidebar
  variable :sidebar_width, "20rem"

  # font
  variable :font_xs, ~FUNC[size(2)]
  variable :font_sm, ~FUNC[size(3)]
  variable :font_md, ~FUNC[size(4)]
  variable :font_lg, ~FUNC[size(5)]
  variable :font_xl, ~FUNC[size(6)]
  variable :font_xxl, ~FUNC[size(7)]

  # gap
  variable :gap_sm, "0.25rem"
  variable :gap_md, "0.5rem"
  variable :gap_lg, "0.75rem"
  variable :gap_xl, "1rem"

  # padding
  variable :padding_sm, "0.25rem"
  variable :padding_md, "0.5rem"
  variable :padding_lg, "0.75rem"
  variable :padding_xl, "1rem"

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Typography
  # ---------------------------------------------------------------------

  # heading
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  style [:heading, :classes, :base_class], ~CSS"""
    color: <%= @color_text %>;
    flex-direction: column;
    align-items: flex-start;
    display: flex;
  """

  style [:heading, :classes, :title_tag_class], ~CSS"""
    font-weight: bold;
  """

  style [:heading, :classes, :inline_class], ~CSS"""
    font-weight: normal;
    font-size: 70%;
  """

  # style [:heading, :classes, :actions_class], ~CSS"""
  # """

  # style [:heading, :decoration, :none], ~CSS"""
  # """
  # style [:heading, :decoration, :accent], ~CSS"""
  # """
  style [:heading, :decoration, :spaced_uppcase], ~CSS"""
    color: <%= @color_text_subtle %>;
    text-transform: uppercase;
    letter-spacing: 0.2rem;

    .<%= class_name(:heading, :classes, :title_tag_class) %> {
      font-weight: 300;
    }
  """

  style [:heading, :size, :sm], ~CSS"""
    font-size: <%= @font_sm %>;
  """

  style [:heading, :size, :md], ~CSS"""
    font-size: <%= @font_md %>;
  """

  style [:heading, :size, :lg], ~CSS"""
    font-size: <%= @font_lg %>;
  """

  style [:heading, :size, :xl], ~CSS"""
    font-size: <%= @font_xl %>;
  """

  style [:heading, :size, :xxl], ~CSS"""
    font-size: <%= @font_xxl %>;
  """

  # ---------------------------------------------------------------------
  # BuenaVista.Components.Navigation
  # ---------------------------------------------------------------------

  # navigation_item
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # style [:navigation_item, :classes, :base_class], ~CSS"""
  # """

  # style [:navigation_item, :state, :default], ~CSS"""
  # """
  # style [:navigation_item, :state, :selected], ~CSS"""
  # """

  # navigation
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  style [:navigation, :classes, :base_class], ~CSS"""
    display: flex;
  """

  style [:navigation, :orientation, :vertical], ~CSS"""
    flex-direction: column;
  """

  style [:navigation, :orientation, :horizontal], ~CSS"""
    gap: <%= @gap_sm %>;
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

  style [:sidebar_layout, :classes, :base_class], ~CSS"""
    display: flex;
  """

  style [:sidebar_layout, :classes, :sidebar_class], ~CSS"""
    width: <%= @sidebar_width %>;
    flex-grow: 1;
  """

  style [:sidebar_layout, :classes, :main_class], ~CSS"""
    min-inline-size: 50%;
    flex-grow: 999;
    flex-basis: 0;
  """

  # style [:sidebar_layout, :position, :left], ~CSS"""
  # """
  style [:sidebar_layout, :position, :right], ~CSS"""
    flex-direction: row-reversed;
  """

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
