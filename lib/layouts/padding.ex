defmodule Scenic.Layouts.Padding do
  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  ######FIX ME#########
  # While this does technically pad something it does not take into account the size of the primitive/component.
  # Top and left padding should work no problem but to pad from the bottom or right the size must be taken into account.

  # Take number of pixels to pad by and coordinates to start padding. Returns {x, y} for padding
  def padding(pix, {x, y} \\ {0, 0}, {x_viewport, y_viewport} \\ @viewport) when is_number(pix) do
    maybe_x = padding_left_or_right(pix, x)
    maybe_y = padding_top_or_bottom(pix, y)
    x =
      case maybe_x >= x_viewport do
        true ->
          x_viewport - pix
        _ ->
          maybe_x
      end

    y =
      case maybe_y >= y_viewport do
        true ->
          y_viewport - pix
        _ ->
          maybe_y
      end

    {x, y}
  end

  # Takes pixels to padd x by.
  # def padding_top(pix, {x, y}) when is_number(pix), do: {padding_top_or_bottom(pix, x), y}

  # def padding_bottom(pix, {x, y}) when is_number(pix), do: {x, padding_top_or_bottom(pix, y)}

  # def padding_left(pix, {x, y}) when is_number(pix), do: {padding_left_or_right(pix, x), y}

  # def padding_right(pix, {x, y}) when is_number(pix), do: {x, padding_left_or_right(pix, y)}

  defp padding_left_or_right(pix, x) when x == 0, do: pix
  defp padding_left_or_right(pix, x) when is_number(pix) and is_number(x), do: x + pix

  defp padding_top_or_bottom(pix, y) when y == 0, do: pix
  defp padding_top_or_bottom(pix, y) when is_number(pix) and is_number(y), do: y - pix
end
