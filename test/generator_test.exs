defmodule BuenaVista.GeneratorTest do
  use ExUnit.Case

  describe "generate_app_components_raw_css/2" do
    test "Writes rules correctly" do
      defmodule TestComponents do
        use BuenaVista.Component

        variant :color, [:regular, :accent], :regular

        component link(assigns) do
          ~H[<div>Link</div>]
        end

        variant :size, [:sm, :md], :md

        component icon(assigns) do
          ~H[<span>Icon</span>]
        end
      end

      defmodule TestComponentsHydrator do
        use BuenaVista.Hydrator,
          nomenclator: BuenaVista.Themes.DefaultNomenclator,
          parent: BuenaVista.Themes.EmptyHydrator

        style :link, :base_class, ~CSS"""
          text-decoration: underline;

          [data-source="internal"] {
            text-decoration: none;
          }
        """

        style :link, :color, :regular, ~CSS"""
          color: black;

          &:hover {
            color: blue;
          }
        """

        style :link, :color, :accent, ~CSS"""
          color: blue;

          & .$icon__base_class.$icon__size__md {
            fill: purple;
          }
        """

        style :icon, :size, :md, ~CSS"""

          .$link__color_accent & {
            border: 1px solid red;
          }
        """
      end

      app = %BuenaVista.Theme.App{
        name: :test,
        nomenclator: %BuenaVista.Theme.Nomenclator{
          module: BuenaVista.Themes.DefaultNomenclator,
          parent_module: BuenaVista.Themes.EmptyNomenclator,
          file: nil,
          overridable?: true
        },
        hydrator: %BuenaVista.Theme.Hydrator{
          module: TestComponentsHydrator,
          parent_module: BuenaVista.Themes.EmptyHydrator,
          file: nil,
          imports: [],
          overridable?: false
        }
      }

      components = TestComponents.get_buenavista_components()

      css = BuenaVista.Generator.generate_app_components_raw_css(app, components)

      assert css === """
              .link {
               text-decoration: underline;
             }
              .link [data-source="internal"] {
               text-decoration: none;
             }
              .link.link-regular {
               color: black;
             }
              .link.link-regular:hover {
               color: blue;
             }
              .link.link-accent {
               color: blue;
             }
              .link.link-accent .icon.icon-md {
               fill: purple;
             }
              .icon {
             }
              .icon.icon-sm {
             }
              .icon.icon-md {
             }
             .link-color-accent  .icon.icon-md {
               border: 1px solid red;
             }
             """
    end
  end
end
