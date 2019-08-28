defmodule LayoutOMatic.Layouts.Circle do

  # A circles size int is the radius and the translate is based on the center
  def translate(%{data: size, styles: %{stroke: stroke}}, max_xy, {starting_x, starting_y}, grid_xy) do
    stroke_fill = elem(stroke, 0)
    x = size + stroke_fill + starting_x

    case fits_in_x?(x, max_xy) do
      #fits in x
      true ->
        {:ok, {x, size + stroke_fill}}

      #doesnt fit in x
      false ->
        #fit in new y?
        y = size * 2 + stroke_fill + starting_y
        case fits_in_y?(y, max_xy) do
          #fits in new y, check x
          true ->
            grid_x = elem(grid_xy, 0) + size
            {:ok, {grid_x, y}}
          false ->
            {:error, "Does not fit in the grid"}
        end
    end
  end

  def fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  def fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
