defmodule LayoutOMatic.Circle do
  @moduledoc """
    Scenic Circle Primitives are sized from a radius and translated from the center where the pin defaults to. This module provides functions to layout
    a single circle and to calculate a circle's area. While these can be used directly, it is used by `LayoutOMatic.PrimitiveLayout`. Circles are drawn
    starting in "standard" position and draw counterclockwise.
  """

  @doc """
  Calculates area of circle. `A = π * r²`
  """
  @spec area(Scenic.Primitive.t()) :: float()
  def area(primitive) do
    %{styles: %{stroke: {stroke_fill, _}}, data: radius} = primitive

    (radius + stroke_fill * 2)
    |> calculate_area()
    |> Float.round(1)
  end

  defp calculate_area(size) when is_integer(size) do
    3.14 * Integer.pow(size, 2)
  end

  defp calculate_area(size) when is_float(size) do
    3.14 * Float.pow(size, 2)
  end

  @doc """
  Applies a translate to a circle primitive from a starting point which is not bound by a bounding box. This lays out circles in a line. Circles
  apply translates from the center.
  TODO:
  * option to lay out by x or y
  * option to add padding between/before/after circles
  """
  @spec from_point_translate(LayoutOMatic.PrimitiveLayout.t()) ::
          {:ok, {number(), number()}, LayoutOMatic.PrimitiveLayout.t()}
  def from_point_translate(%{wrap: true} = layout),
    do: translate(layout)

  def from_point_translate(layout) do
    %{primitive: primitive, starting_xy: starting_xy, grid_xy: {grid_x, grid_y} = grid_xy} =
      layout

    %{styles: %{stroke: {stroke_fill, _}}, data: size} = primitive
    {starting_x, starting_y} = starting_xy
    diameter = size * 2

    if starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      x = grid_x + stroke_fill * 2 + size
      y = grid_y + stroke_fill * 2 + size
      new_layout = %{layout | starting_xy: {x, y}}
      {:ok, {x, y}, new_layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_x = starting_x + diameter + stroke_fill * 2

      # update the starting_xy with where this primitive is being translated
      # the next primitive will use this xy
      new_layout = Map.put(layout, :starting_xy, {potential_x, starting_y})
      {:ok, {potential_x, starting_y}, new_layout}
    end
  end

  @spec translate(LayoutOMatic.PrimitiveLayout.t()) ::
          {:ok, {number, number}, LayoutOMatic.PrimitiveLayout.t()} | {:error, binary()}
  def translate(layout) do
    %{
      primitive: primitive,
      starting_xy: starting_xy,
      max_xy: max_xy,
      grid_xy: grid_xy,
      padding: padding
    } = layout

    %{data: size, styles: %{stroke: {stroke_fill, _}}} = primitive
    {grid_x, grid_y} = grid_xy
    {starting_x, starting_y} = starting_xy
    diameter = size * 2 + stroke_fill

    if starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      x = grid_x + stroke_fill + size + padding
      y = grid_y + stroke_fill + size + padding
      layout = %{layout | starting_xy: {x, y}}
      {:ok, {x, y}, layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_x = starting_x + diameter + stroke_fill + padding
      # since cirlces translate from the center, we need to add the radius so we can be
      # sure it fits in the grid
      if fits_in_x?(potential_x + size + padding, max_xy) do
        # fits in x

        # fit in y?
        if fits_in_y?(starting_y, max_xy) do
          # fits in grid

          # update the starting_xy with where this primitive is being translated
          # the next primitive will use this xy
          new_layout = Map.put(layout, :starting_xy, {potential_x, starting_y})
          {:ok, {potential_x, starting_y}, new_layout}

          # Does not fit
        else
          # might want to change this later to not error but to log that something
          # doesn't fit. Might be useful later for a size_to_fit
          {:error, "Does not fit in grid"}
        end

        # doesnt fit in x
      else
        # fit in new y?
        # if it doesnt fit in x anymore, try to move down by y and start a new row
        # the grid_y(our original starting place)/diameter/size/stroke fill
        # diameter + size is because the circle translates by the center which means we
        # need diamter and radius in order for circles to not overlap
        new_y = starting_y + diameter + stroke_fill + padding

        # need to do the same thing as x, check if the entire circle will fit
        if fits_in_y?(new_y + size, max_xy) do
          # fits in new y, check x

          sized_x = grid_x + size + stroke_fill + padding

          new_layout =
            layout
            |> Map.put(:grid_xy, {grid_x, new_y})
            |> Map.put(:starting_xy, {sized_x, new_y})

          {:ok, {sized_x, new_y}, new_layout}
        else
          {:error, "Does not fit in the grid"}
        end
      end
    end
  end

  defp fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  defp fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
