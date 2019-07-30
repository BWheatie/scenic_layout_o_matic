defmodule LayoutOMatic.Layouts.LayoutGuards do
  # arc and sector evaluate to the same thing as do line and rrect
  defguard is_arc(value) when is_tuple(value) and tuple_size(value) == 3
  defguard is_circle(value) when is_integer(value)
  defguard is_rect(value) when is_tuple(value) and tuple_size(value) == 2

  defguard is_rrect(value)
           when is_tuple(value) and is_tuple(elem(value, 0)) and is_tuple(elem(value, 1))

  defguard is_line(value)
           when is_tuple(value) and is_tuple(elem(value, 0)) and is_tuple(elem(value, 1))

  defguard is_path(value) when is_list(value) and hd(value) == :begin and length(value) <= 3

  defguard is_quad(value)
           when is_tuple(value) and is_tuple(elem(value, 0)) and
                  is_tuple(
                    elem(value, 1) and
                      is_tuple(elem(value, 2)) and is_tuple(elem(value, 3))
                  )

  defguard is_sector(value) when is_tuple(value) and tuple_size(value) == 3

  defguard is_triangle(value)
           when is_tuple(value) and is_tuple(elem(value, 0)) and
                  is_tuple(elem(value, 1)) and tuple_size(value) == 3
end
