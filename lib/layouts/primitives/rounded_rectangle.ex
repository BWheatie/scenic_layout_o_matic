defmodule LayoutOMatic.Layouts.Primitives.RoundedRectangle do
  @default_stroke {1, :white}
  # A circles size int is the radius and the translate is based on the center
  def translate(
        %{
          primitive: primitive,
          starting_xy: starting_xy,
          max_xy: max_xy,
          grid_xy: grid_xy
        } = layout
      ) do
    %{data: {width, height, _}} = primitive
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
            {starting_x + width + stroke_fill, starting_y + stroke_fill}
          )

        {:ok, {starting_x + stroke_fill / 2, starting_y + stroke_fill / 2}, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + width + stroke_fill, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y + height + stroke_fill, max_xy) do
              true ->
                # fits
                layout =
                  Map.put(
                    layout,
                    :starting_xy,
                    {starting_x + width + stroke_fill, starting_y + stroke_fill}
                  )

                {:ok, {starting_x, starting_y}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + height + stroke_fill

            case fits_in_y?(new_y, max_xy) do
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x, new_y})
                  |> Map.put(:starting_xy, {width + stroke_fill, new_y})

                {:ok, {grid_x + stroke_fill / 2, new_y}, new_layout}

              false ->
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
