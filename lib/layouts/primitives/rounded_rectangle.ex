defmodule LayoutOMatic.RoundedRectangle do
  @moduledoc """
  Scenic RoundedRectangle Primitives are sized from a {width, height, radius} and translated from the top left corner where the pin defaults to. This
  module provides functions to layout a single rounded rectangle and to calculate a rounded rectangle's area. While these can be used directly, it is used
  by `LayoutOMatic.PrimitiveLayout`.
  """
  @type xy :: {number(), number()}
  @type error_string :: String.t()

  @default_stroke {1, :white}

  @doc """
  Calculates area of rounded rectangle. `A = LW - (4-π)r²`
  """
  @spec area(Scenic.Primitive.t()) :: float()
  def area(%{data: {_, _, r}} = primitive) when is_integer(r) do
    %{styles: %{stroke: {stroke_fill, _}}, data: {x, y, r}} = primitive

    Float.round(x * y + stroke_fill * 2 - (4 - 3.14) * Integer.pow(r, 2), 1)
  end

  def area(%{data: {_, _, r}} = primitive) when is_float(r) do
    %{styles: %{stroke: {stroke_fill, _}}, data: {x, y, r}} = primitive

    Float.round(x * y + stroke_fill * 2 - (4 - 3.14) * Float.pow(r, 2), 1)
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
    %{
      primitive: %{data: {width, _, _}} = primitive,
      starting_xy: starting_xy,
      grid_xy: {grid_x, grid_y} = grid_xy
    } =
      layout

    stroke_fill =
      case Map.get(primitive, :styles) do
        nil ->
          elem(@default_stroke, 0)

        styles when is_map(styles) ->
          %{stroke: stroke} = styles
          elem(stroke, 0)
      end

    {starting_x, starting_y} = starting_xy

    if starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      x = grid_x + stroke_fill + width
      y = grid_y + stroke_fill + width
      new_layout = %{layout | starting_xy: {x, y}}
      {:ok, {x, y}, new_layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_x = starting_x + width + stroke_fill

      # update the starting_xy with where this primitive is being translated
      # the next primitive will use this xy
      new_layout = Map.put(layout, :starting_xy, {potential_x, starting_y})
      {:ok, {potential_x, starting_y}, new_layout}
    end
  end

  @spec translate(LayoutOMatic.PrimitiveLayout.t()) ::
          {:ok, xy, LayoutOMatic.PrimitiveLayout.t()} | {:error, String.t()}
  def translate(layout) do
    %{
      primitive: primitive,
      starting_xy: starting_xy,
      max_xy: max_xy,
      grid_xy: grid_xy,
      padding: padding
    } = layout

    %{data: {width, height, _}} = primitive
    {grid_x, grid_y} = grid_xy
    {starting_x, starting_y} = starting_xy

    stroke_fill =
      case Enum.member?(primitive.styles, :stroke) do
        false ->
          elem(@default_stroke, 0)

        false ->
          primitive.styles.stroke
      end

    if starting_xy == grid_xy do
      layout =
        Map.put(
          layout,
          :starting_xy,
          {starting_x + width + stroke_fill + padding, starting_y + stroke_fill}
        )

      {:ok, {starting_x + stroke_fill / 2, starting_y + stroke_fill / 2}, layout}
    else
      # already in a new group, use starting_xy
      if fits_in_x?(starting_x + width + stroke_fill + padding, max_xy) do
        # fits in x

        # fit in y?
        if fits_in_y?(starting_y + height + stroke_fill + padding, max_xy) do
          # fits
          layout =
            Map.put(
              layout,
              :starting_xy,
              {starting_x + width + stroke_fill + padding, starting_y + stroke_fill}
            )

          {:ok, {starting_x, starting_y}, layout}

          # Does not fit
        else
          {:error, "Does not fit in grid"}
        end

        # doesnt fit in x
      else
        # fit in new y?
        new_y = grid_y + height + stroke_fill + padding

        if fits_in_y?(new_y, max_xy) do
          new_layout =
            layout
            |> Map.put(:grid_xy, {grid_x, new_y})
            |> Map.put(:starting_xy, {width + stroke_fill + padding, new_y})

          {:ok, {grid_x + stroke_fill, new_y}, new_layout}
        else
          {:error, "Does not fit in the grid"}
        end
      end
    end
  end

  def fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  def fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
