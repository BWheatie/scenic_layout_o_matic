defmodule LayoutOMatic.Layouts.Components.Slider do
  # Buttons size based on :button_font_size with 20 being the default; width/height override
  @default_width 300

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

    height = 18
    width = Map.get(component, :styles, @default_width)

    case starting_xy == grid_xy do
      true ->
        layout =
          Map.put(
            layout,
            :starting_xy,
            {starting_x + width, starting_y}
          )

        {:ok, {starting_x + 3, starting_y + 2}, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + width, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y, max_xy) do
              true ->
                # fits
                layout = Map.put(layout, :starting_xy, {starting_x + width, starting_y})

                {:ok, {starting_x + 3, starting_y + 2}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + height

            case fits_in_y?(new_y, max_xy) do
              true ->
                new_layout =
                  layout
                  |> Map.put(:grid_xy, {grid_x, new_y})
                  |> Map.put(:starting_xy, {width, new_y})

                {:ok, {grid_x + 3, new_y + 2}, new_layout}

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
