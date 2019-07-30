defmodule LayoutOMatic.Layouts.Circle do
  def translate(potential_translate, max_xy, starting_xy) do
    case fits_in_x?(potential_translate, max_xy) do
      true ->
        true

      false ->
        case fits_in_y?(potential_translate, max_xy) do
          true ->
            fits_in_x?(translate_circle_y(size, starting_xy), max_xy)

          false ->
            raise "Doesnt fit"
        end
    end
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
