defmodule LayoutOMatic.Group do
  @doc """
  Applies a translate to a circle primitive from a starting point which is not bound by a bounding box. This lays out circles in a line. Circles
  apply translates from the center.
  TODO:
  * option to lay out by x or y
  * option to add padding between/before/after circles
  """
  @spec from_point_translate(LayoutOMatic.PrimitiveLayout.t()) ::
          {:ok, {number(), number()}, LayoutOMatic.PrimitiveLayout.t()}
  def from_point_translate(%{axis: :x} = layout) do
    %{
      starting_xy: starting_xy,
      bounding_box: {bounding_box_x, _}
    } =
      layout

    {starting_x, starting_y} = starting_xy

    if starting_xy == layout.grid_xy do
      # if starting new group of primitives use the grid translate
      new_layout = %{
        layout
        | starting_xy: {starting_x + bounding_box_x + layout.padding, starting_y}
      }

      {:ok, starting_xy, new_layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_x = starting_x + bounding_box_x + layout.padding

      # update the starting_xy with where this primitive is being translated
      # the next primitive will use this xy
      new_layout = Map.put(layout, :starting_xy, {potential_x, starting_y})
      {:ok, {starting_x, starting_y}, new_layout}
    end
  end

  def from_point_translate(%{axis: :y} = layout) do
    %{
      starting_xy: {starting_x, starting_y},
      bounding_box: {_, bounding_box_y}
    } =
      layout

    if layout.starting_xy == layout.grid_xy do
      # if starting new group of primitives use the bounding_box translate
      new_layout = %{layout | starting_xy: {starting_x, bounding_box_y}}
      {:ok, layout.starting_xy, new_layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_y = starting_y + bounding_box_y + layout.padding

      # update the starting_xy with where this primitive is being translated
      # the next primitive will use this xy
      new_layout = Map.put(layout, :starting_xy, {starting_x, potential_y})
      {:ok, {starting_x, starting_y + layout.padding}, new_layout}
    end
  end
end
