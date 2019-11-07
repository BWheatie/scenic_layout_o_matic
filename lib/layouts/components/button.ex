defmodule LayoutOMatic.Layouts.Components.Button do
  # Buttons size based on :button_font_size with 20 being the default; width/height override
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
    {_, text} = Map.get(component, :data)

  styles = button_size(component)
  %{font_size: font_size, ascent: ascent, fm_width: fm_width} = get_font_metrics(text, Map.get(styles, :button_font_size))

  height =
    case Map.get(styles, :height) do
      nil -> font_size + ascent
      :auto -> font_size + ascent
      height when is_number(height) and height > 0 -> height
    end

  width =
    case Map.get(styles, :width) do
      nil -> fm_width + ascent + ascent
      :auto -> fm_width + ascent + ascent
      width when is_number(width) and width > 0 -> width
    end

    {starting_x, starting_y} = starting_xy
    {grid_x, grid_y} = grid_xy

    case starting_xy == grid_xy do
      true ->
        layout = Map.put(layout, :starting_xy, {starting_x + width, starting_y})
        {:ok, {starting_x, starting_y}, layout}

      false ->
        # already in a new group, use starting_xy
        case fits_in_x?(starting_x + width, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(starting_y + height, max_xy) do
              true ->
                # fits
                layout = Map.put(layout, :starting_xy, {starting_x + width, starting_y})
                {:ok, {starting_x, starting_y}, layout}

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = grid_y + height

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
  def button_size(%{styles: %{width: _, height: _, button_font_size: _}} = styles), do: styles
  def button_size(%{styles: %{width: _, height: _}} = styles), do: Map.put(styles, :button_font_size, @default_font_size)
  def button_size(_), do: Map.new(button_font_size: @default_font_size)

  def get_font_metrics(text, font_size) do
    fm = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)
    %{font_size: font_size, ascent: ascent, fm_width: fm_width}
  end

  def fits_in_x?(potential_x, {max_x, _}),
    do: potential_x <= max_x

  def fits_in_y?(potential_y, {_, max_y}),
    do: potential_y <= max_y
end
