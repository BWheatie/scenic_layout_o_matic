defmodule LayoutOMatic.Layouts.Circle do
  # A circles size int is the radius and the translate is based on the center
  def translate(%{data: size, styles: %{stroke: stroke}}, max_xy, {starting_x, starting_y}) do
    stroke_fill = elem(stroke, 0)
    x = translate_x(size + stroke_fill, starting_x)

    case fits_in_x?(x, max_xy) do
      #fits in x
      true ->
        {:ok, {x, size + stroke_fill}}

      #doesnt fit in x
      false ->
        #fit in new y?
        y = translate_y(size, starting_y)
        case fits_in_y?(y, max_xy) do
          #fits in new y, check x
          true ->
            fits_in_x?(x, max_xy)

            {:ok, {x, y}}

          false ->
            {:error, "Does not fit in the grid"}
        end
    end
  end

  def translate_x(size, starting_x),
    do: starting_x + size

  def translate_y(size, starting_y),
    do: starting_y + size

  def fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  def fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
