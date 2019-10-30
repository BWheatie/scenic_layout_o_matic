defmodule LayoutOMatic.Layouts.Components.Checkbox do
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
    {_, {text, _}} = Map.get(component, :data)

    {starting_x, starting_y} = starting_xy
    {grid_x, grid_y} = grid_xy

    fm = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    ascent = FontMetrics.ascent(@default_font_size, fm)
    fm_width = FontMetrics.width(text, @default_font_size, fm)
    space_width = FontMetrics.width(' ', @default_font_size, fm)
    box_width = fm_width + ascent + space_width * 2
    box_height = trunc(ascent) + 1

    case starting_xy == grid_xy do
      true ->
        layout =
          Map.put(
            layout,
            :starting_xy,
            {starting_x + box_width + space_width * 2, starting_y + box_height}
          )

        {:ok, {trunc(starting_x + space_width), starting_y + box_height}, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + box_width + space_width, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y + box_height + ascent, max_xy) do
              true ->
                # fits
                layout =
                  Map.put(
                    layout,
                    :starting_xy,
                    {starting_x + box_width + space_width, starting_y}
                  )

                {:ok, {trunc(starting_x), starting_y}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + box_height * 2.5

            case fits_in_y?(new_y, max_xy) do
              # fits in new y, check x
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x + space_width, new_y})
                  |> Map.put(:starting_xy, {box_width, new_y})

                {:ok, {trunc(grid_x + space_width), new_y}, new_layout}

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
