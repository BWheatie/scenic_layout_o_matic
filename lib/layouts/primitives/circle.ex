defmodule LayoutOMatic.Layouts.Primitives.Circle do
  # A circles size int is the radius and the translate is based on the center
  def translate(
        %{
          primitive: primitive,
          starting_xy: starting_xy,
          max_xy: max_xy,
          grid_xy: grid_xy
        } = layout
      ) do
    %{data: size, styles: %{stroke: stroke}} = primitive
    {grid_x, grid_y} = grid_xy
    {starting_x, starting_y} = starting_xy
    diameter = size * 2

    # it will increase size by the stoke in order that circles do not overlap at all.
    # In the future this will be possible to adjust with padding
    stroke_fill = elem(stroke, 0)

    case starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      true ->
        x = grid_x + stroke_fill + size
        y = grid_y + stroke_fill + size
        layout = %{layout | starting_xy: {x, y}}
        {:ok, {x, y}, layout}

      false ->
        # already in a new group, use starting_xy

        # x to start at/diameter/stroke fill
        potential_x = starting_x + diameter + stroke_fill
        # since cirlces translate from the center, we need to add the radius so we can be
        # sure it fits in the grid
        case fits_in_x?(potential_x + size, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y, max_xy) do
              true ->
                # fits in grid

                # update the starting_xy with where this primitive is being translated
                # the next primitive will use this xy
                new_layout = Map.put(layout, :starting_xy, {potential_x, starting_y})
                {:ok, {potential_x, starting_y}, new_layout}

              # Does not fit
              false ->
                # might want to change this later to not error but to log that something
                # doesn't fit. Might be useful later for a size_to_fit
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            # if it doesnt fit in x anymore, try to move down by y and start a new row
            # the grid_y(our original starting place)/diameter/size/stroke fill
            # diameter + size is because the circle translates by the center which means we
            # need diamter and radius in order for circles to not overlap
            new_y = starting_y + diameter + stroke_fill

            # need to do the same thing as x, check if the entire circle will fit
            case fits_in_y?(new_y + size, max_xy) do
              # fits in new y, check x
              true ->
                sized_x = grid_x + size + stroke_fill

                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x, new_y})
                  |> Map.put(:starting_xy, {sized_x, new_y})

                {:ok, {sized_x, new_y}, new_layout}

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
