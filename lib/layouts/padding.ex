# defmodule LayoutOMatic.Layouts.Padding do

#   @viewport :scenic_layout_o_matic
#             |> Application.get_env(:viewport)
#             |> Map.get(:size)

#   ###### FIX ME#########
#   # While this does technically pad something it does not take into account the size of the primitive/component.
#   # Top and left padding should work no problem but to pad from the bottom or right the size must be taken into account.

#   # Take number of pixels to pad by and coordinates to start padding. Returns {x, y} for padding
#   def pad(pix, {x, y} \\ {0, 0}, {x_viewport, y_viewport} \\ @viewport) when is_number(pix) do
#     maybe_x = do_padding(pix, x)
#     maybe_y = do_padding(pix, y)

#     x =
#       case maybe_x >= x_viewport do
#         true ->
#           x_viewport - pix

#         _ ->
#           maybe_x
#       end

#     y =
#       case maybe_y >= y_viewport do
#         true ->
#           y_viewport - pix

#         _ ->
#           maybe_y
#       end

#     {x, y}
#   end

#   # Takes pixels to padd x by.
#   def left(pix, x) when is_number(pix), do: do_padding(pix, x)

#   def right(pix, x) when is_number(pix), do: do_padding(pix, x)

#   def top(pix, y) when is_number(pix), do: do_padding(pix, y)

#   def bottom(pix, y) when is_number(pix), do: do_padding(pix, y)

#   defp do_padding(pix, start_point) when start_point == 0, do: pix
#   defp do_padding(pix, start_point) when is_number(pix) and is_number(start_point), do: start_point + pix
# end
