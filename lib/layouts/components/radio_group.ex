defmodule LayoutOMatic.Layouts.Components.RadioGroup do
  # Checkbox size based on :button_font_size with 20 being the default; width/height override
  @default_font_size 20
  @default_font :roboto

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
    metrics = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    font_size = Map.get(styles, :button_font_size, @default_font_size)
    ascent = FontMetrics.ascent(@default_font_size, metrics)

    fm_width =
      Enum.reduce(items, 0, fn {text, _}, w ->
        width = FontMetrics.width(text, font_size, metrics)

        max(w, width)
      end)

    space_width = FontMetrics.width(' ', @default_font_size, metrics)
    box_width = fm_width + ascent + space_width * 2
    box_height = ascent + 1
    outer_radius = ascent * 0.5

    case starting_xy == grid_xy do
      true ->
        x = starting_x + box_width + space_width + outer_radius
        y = starting_y + outer_radius

        layout = Map.put(layout, :starting_xy, {x, y})
        {:ok, {starting_x + space_width, starting_y + space_width}, layout}

      false ->
        # already in a new group, use starting_xy
        x = starting_x + box_width + space_width + outer_radius

        case fits_in_x?(x, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y + box_height + space_width, max_xy) do
              true ->
                # fits
                layout = Map.put(layout, :starting_xy, {x, starting_y + space_width})
                {:ok, {x, starting_y + space_width}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + box_height + outer_radius

            case fits_in_y?(new_y, max_xy) do
              # fits in new y, check x
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x + space_width, new_y})
                  |> Map.put(:starting_xy, {box_width, new_y})

                {:ok, {grid_x + space_width, new_y}, new_layout}

              false ->
                {:error, "Does not fit in the grid"}
            end
        end
    end
  end

  def fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  def fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
