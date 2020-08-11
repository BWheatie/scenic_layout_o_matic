defmodule LayoutOMatic.TextField do
  # Buttons size based on :button_font_size with 20 being the default; width/height override
  @default_font_size 22
  @char_width 10

  @default_width @char_width * 24
  @default_height @default_font_size * 1.5

  @spec translate(%{
          component: map,
          starting_xy: {number, number},
          grid_xy: {number, number},
          max_xy: {number, number}
        }) ::
          {:error, <<_::160, _::_*32>>}
          | {:ok, {number, number},
             %{
               grid_xy: {number, number},
               max_xy: number,
               primitive: %{data: number, styles: map},
               starting_xy: {number, number}
             }}
  def translate(
        %{
          component: component,
          starting_xy: starting_xy,
          grid_xy: grid_xy,
          max_xy: max_xy
        } = layout
      ) do
    styles = Map.get(component, :styles, %{})
    width = Map.get(styles, :width, @default_width)
    height = Map.get(styles, :height, @default_height)
    {starting_x, starting_y} = starting_xy
    {grid_x, grid_y} = grid_xy

    if starting_xy == grid_xy do
      layout =
        Map.put(
          layout,
          :starting_xy,
          {starting_x + width, starting_y}
        )

      {:ok, {starting_x + 3, starting_y + 2}, layout}
    else
      if fits_in_x?(starting_x + width, max_xy) do
        if fits_in_y?(starting_y, max_xy) do
          layout = Map.put(layout, :starting_xy, {starting_x + width, starting_y})

          {:ok, {starting_x + 3, starting_y + 2}, layout}
        else
          {:error, "Does not fit in grid"}
        end

        new_y = grid_y + height

        if fits_in_y?(new_y, max_xy) do
          new_layout =
            layout
            |> Map.put(:grid_xy, {grid_x, new_y})
            |> Map.put(:starting_xy, {width, new_y})

          {:ok, {grid_x + 3, new_y + 2}, new_layout}
        else
          {:error, "Does not fit in grid"}
        end
      end
    end
  end

  defp fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  defp fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
