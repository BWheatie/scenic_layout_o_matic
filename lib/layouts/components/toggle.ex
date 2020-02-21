defmodule LayoutOMatic.Toggle do
  # Buttons size based on :button_font_size with 20 being the default; width/height override
  @default_thumb_radius 8
  @default_padding 2
  @default_border_width 2

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
    {starting_x, starting_y} = starting_xy
    {grid_x, grid_y} = grid_xy
    styles = Map.get(component, :styles, %{})

    thumb_radius = Map.get(styles, :thumb_radius, @default_thumb_radius)
    padding = Map.get(styles, :padding, @default_padding)
    border_width = Map.get(styles, :border_width, @default_border_width)

    # calculate the dimensions of the track
    track_height = thumb_radius * 2 + 2 * padding + 2 * border_width
    track_width = thumb_radius * 4 + 2 * padding + 2 * border_width

    case starting_xy == grid_xy do
      true ->
        layout =
          Map.put(
            layout,
            :starting_xy,
            {starting_x + track_width + 3, starting_y}
          )

        {:ok, {starting_x, starting_y + track_height}, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + track_width, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y, max_xy) do
              true ->
                # fits
                layout = Map.put(layout, :starting_xy, {starting_x + track_width + 3, starting_y})

                {:ok, {starting_x, starting_y + track_height}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + track_height

            case fits_in_y?(new_y, max_xy) do
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x, new_y})
                  |> Map.put(:starting_xy, {track_width + 3, new_y})

                {:ok, {grid_x, new_y}, new_layout}

              false ->
                {:error, "Does not fit in the grid"}
            end
        end
    end
  end

  defp fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  defp fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
