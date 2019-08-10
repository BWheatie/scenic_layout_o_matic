defmodule LayoutOMatic.Layouts.Circle do
  def translate(size, max_xy, starting_xy) do
    x = translate_x(size, starting_xy)
    y = translate_y(size, starting_xy)

    case fits_in_x?({x, y}, max_xy) do
      #fits in x
      true ->
        true

      #doesnt fit in x
      false ->
        #fit in new y?
        case fits_in_y?({x, y}, max_xy) do
          #fits in new y, check x
          true ->
            fits_in_x?(translate_y(size, starting_xy), max_xy)

          false ->
            raise "Doesnt fit"
        end
    end

    {x, y}
  end

  def translate_x(size, starting_xy),
    do: {elem(starting_xy, 0) + size, elem(starting_xy, 1)}

  def translate_y(size, starting_xy),
    do: {elem(starting_xy, 0), elem(starting_xy, 1) + size}

  def fits_in_x?(potential_translate, max_xy),
    do: elem(potential_translate, 0) <= elem(max_xy, 0)

  def fits_in_y?(potential_translate, max_xy),
    do: elem(potential_translate, 1) <= elem(max_xy, 1)
end
