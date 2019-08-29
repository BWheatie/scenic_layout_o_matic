defmodule LayoutOMatic.Layouts.Circle do
  # A circles size int is the radius and the translate is based on the center
  def translate(
        %{data: size, styles: %{stroke: stroke}},
        max_xy,
        {starting_x, starting_y} = starting_xy,
        {grid_x, grid_y} = grid_xy
      ) do
    size_stroke_fill = elem(stroke, 0) + size
    case starting_xy == grid_xy do
      # if starting new group of primitives use the grid translate
      true ->
        {:ok, {grid_x + size_stroke_fill, grid_y + size_stroke_fill}}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + size + size_stroke_fill, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y , max_xy) do
              true ->
                # fits
                {:ok, {starting_x + size + size_stroke_fill, starting_y}}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + (size * 3) + elem(stroke, 0)

            case fits_in_y?(new_y, max_xy) do
              # fits in new y, check x
              true ->
                grid_x = elem(grid_xy, 0) + size + elem(stroke, 0)
                {:ok, {grid_x, new_y}}

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
