defmodule LayoutOMatic.Dropdown do
  # Checkbox size based on :button_font_size with 20 being the default; width/height override
  @default_font_size 20
  @default_font :roboto
  @default_drop_direction :down

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
    {_, {items, _}} = Map.get(component, :data)
    {starting_x, starting_y} = starting_xy
    {grid_x, grid_y} = grid_xy
    styles = Map.get(component, :styles, %{})
    font_size = Map.get(styles, :button_font_size, @default_font_size)
    metrics = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    ascent = FontMetrics.ascent(font_size, metrics)

    # find the width of the widest item
    fm_width =
      Enum.reduce(items, 0, fn {text, _}, w ->
        width = FontMetrics.width(text, font_size, metrics)

        max(w, width)
      end)

    width =
      case Map.get(styles, :width) do
        nil -> fm_width + ascent * 3
        :auto -> fm_width + ascent * 3
        width when is_number(width) and width > 0 -> width
      end

    height =
      case Map.get(styles, :height) do
        nil -> font_size + ascent
        :auto -> font_size + ascent
        height when is_number(height) and height > 0 -> height
      end

    # calculate the drop box measures
    item_count = Enum.count(items)
    drop_height = item_count * height
    drop_direction = Map.get(styles, :direction, @default_drop_direction)

    case starting_xy == grid_xy do
      true ->
        xy =
          case drop_direction do
            :down ->
              {starting_x, starting_y}

            :up ->
              {starting_x, starting_y + drop_height}
          end

        layout = Map.put(layout, :starting_xy, {starting_x + width, starting_y})
        {:ok, xy, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + width, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y + height + drop_height, max_xy) do
              true ->
                # fits
                xy =
                  case drop_direction do
                    :down ->
                      {starting_x, starting_y}

                    :up ->
                      {starting_x, starting_y + drop_height}
                  end

                layout = Map.put(layout, :starting_xy, {starting_x + width, starting_y})
                {:ok, xy, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y =
              case drop_direction do
                :down ->
                  grid_y + height + drop_height

                :up ->
                  grid_y + height + drop_height * 2
              end

            case fits_in_y?(new_y, max_xy) do
              # fits in new y, check x
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x, new_y})
                  |> Map.put(:starting_xy, {width, new_y})

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
