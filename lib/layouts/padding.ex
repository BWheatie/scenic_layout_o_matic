defmodule Scenic.Layouts.Padding do
  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  # Take number of pixels to pad by and coordinates to start padding. Returns {x, y} for padding
  def padding(pix, points \\ @viewport) when is_number(pix) and is_number(points) do
    case points do
      @viewport ->
        x = padding_bottom_or_right(pix, elem(points, 0)) - padding_top_or_left(pix, 0)
        y = padding_bottom_or_right(pix, elem(points, 1)) - padding_top_or_left(pix, 0)

        {x, y}

      points ->
        x =
          padding_bottom_or_right(pix, elem(points, 0)) -
            padding_top_or_left(pix, elem(points, 0))

        y =
          padding_bottom_or_right(pix, elem(points, 1)) -
            padding_top_or_left(pix, elem(points, 1))

        {x, y}
    end
  end

  def padding_top(pix, point) when is_number(pix) and is_number(point), do: padding_top_or_left(pix, point)

  def padding_bottom(pix, point) when is_number(pix) and is_number(point), do: padding_bottom_or_right(pix, point)

  def padding_left(pix, point) when is_number(pix) and is_number(point), do: padding_top_or_left(pix, point)

  def padding_right(pix, point) when is_number(pix) and is_number(point), do: padding_bottom_or_right(pix, point)

  defp padding_top_or_left(pix, point) when point == 0, do: pix
  defp padding_top_or_left(pix, point) when is_number(pix) and is_number(point), do: point + pix

  defp padding_bottom_or_right(pix, point) when point == 0, do: pix
  defp padding_bottom_or_right(pix, point) when is_number(pix) and is_number(point), do: point - pix
end
