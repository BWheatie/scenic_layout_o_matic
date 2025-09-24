defmodule LayoutOMatic.Rectangle do
  @moduledoc """
  Scenic Rectangle Primitives are sized from a {width, height} and translated from the top left corner where the pin defaults to. This module provides
  functions to layout a single rectangle and to calculate a rectangle's area. While these can be used directly, it is used by
  `LayoutOMatic.PrimitiveLayout`.
  """
  @type xy :: {number(), number()}
  @type error_string :: String.t()

  @default_stroke {1, :white}

  @doc """
  Calculates area of rectangle. `A = x * y`
  """
  @spec area(Scenic.Primitive.t()) :: pos_integer()
  def area(primitive) do
    %{styles: %{stroke: {stroke_fill, _}}, data: {x, y}} = primitive

    x * y + stroke_fill * 2
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
  def from_point_translate(%{axis: :x} = layout) do
    %{primitive: primitive, starting_xy: starting_xy, grid_xy: {grid_x, grid_y} = grid_xy} =
      layout

    %{styles: styles, data: {width, _}} = primitive

    stroke_fill =
      if Map.has_key?(styles, :stroke) do
        elem(styles.stroke, 0)
      else
        0
      end

    {starting_x, starting_y} = starting_xy

    if starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      x = grid_x + stroke_fill + width
      y = grid_y + stroke_fill + width
      new_layout = %{layout | starting_xy: {x, y}}
      {:ok, {starting_x, y}, new_layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_x = starting_x + width + stroke_fill + layout.padding

      # update the starting_xy with where this primitive is being translated
      # the next primitive will use this xy
      new_layout = Map.put(layout, :starting_xy, {potential_x, starting_y})
      {:ok, {starting_x, starting_y}, new_layout}
    end
  end

  def from_point_translate(%{axis: :y} = layout) do
    %{primitive: primitive, starting_xy: starting_xy, grid_xy: {grid_x, grid_y} = grid_xy} =
      layout

    %{styles: styles, data: {_, height}} = primitive

    stroke_fill =
      if Map.has_key?(styles, :stroke) do
        elem(styles.stroke, 0)
      else
        0
      end

    {starting_x, starting_y} = starting_xy

    if starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      x = grid_x + stroke_fill + height
      y = grid_y + stroke_fill + height
      new_layout = %{layout | starting_xy: {x, y}}
      {:ok, {x, y}, new_layout}
    else
      # already in a new group, use starting_xy

      # x to start at/diameter/stroke fill
      potential_y = starting_y + height + stroke_fill + layout.padding

      # update the starting_xy with where this primitive is being translated
      # the next primitive will use this xy
      new_layout = Map.put(layout, :starting_xy, {starting_x, potential_y})
      {:ok, {starting_x, potential_y}, new_layout}
    end
  end

  @doc """
  Translates a given rectangle within an existing group bounding box. It reflows the rectangle when any part exceeds the bounding box. Errors when
  the rectangle does not fit within the bounding box. While this can be used directly, it is best used through `LayoutOMatic.PrimitiveLayout`.
  """
  @spec translate(LayoutOMatic.PrimitiveLayout.t()) ::
          {:ok, xy, LayoutOMatic.PrimitiveLayout.t()} | {:error, error_string()}
  def translate(layout) do
    %{
      primitive: primitive,
      starting_xy: starting_xy,
      max_xy: max_xy,
      grid_xy: grid_xy,
      padding: padding
    } = layout

    # Problem here is it assumes the primitives are the same. The primitive changes but the starting_xy doesn't get updated. Need to find a way to track old xy until it's points are no longer useful.

    %{data: {width, _}} = primitive
    {grid_x, grid_y} = grid_xy
    {starting_x, starting_y} = starting_xy

    stroke_fill =
      case Map.get(primitive, :styles) do
        nil ->
          elem(@default_stroke, 0)

        styles when is_map(styles) ->
          %{stroke: stroke} = styles
          elem(stroke, 0)
      end

    case starting_xy == grid_xy do
      true ->
        layout =
          Map.put(
            layout,
            :starting_xy,
            {starting_x + width + stroke_fill + padding, starting_y + stroke_fill}
          )

        {:ok, {starting_x + stroke_fill, starting_y + stroke_fill}, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + width + stroke_fill + padding, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y, max_xy) do
              true ->
                # fits
                layout =
                  Map.put(
                    layout,
                    :starting_xy,
                    {starting_x + width + stroke_fill + padding, starting_y}
                  )

                {:ok, {starting_x, starting_y}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            %{data: {_, prev_height}} = Map.get(layout, :prev_primitive)
            # fit in new y?
            new_y = grid_y + prev_height + stroke_fill + padding

            case fits_in_y?(new_y, max_xy) do
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x, new_y})
                  |> Map.put(:starting_xy, {grid_x + width + stroke_fill + padding, new_y})

                {:ok, {grid_x + stroke_fill, new_y}, new_layout}

              false ->
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
