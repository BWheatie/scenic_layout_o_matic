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

    %{height: requested_height, width: requested_width, button_font_size: font_size} =
      case Map.get(component, :styles) do
        map when map_size(map) == 3 ->
          map
        map when map_size(map) == 2 ->
          Map.put(map, :button_font_size, @default_font_size)
      end

    {starting_x, starting_y} = starting_xy
    {grid_x, grid_y} = grid_xy
    metrics = get_font_metrics(text, font_size)
    height = get_height(requested_height, metrics)
    width = get_width(requested_width, metrics)

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

  defp get_width(width, %{fm_width: fm_width, ascent: ascent}) do
    case width do
      nil -> fm_width + ascent + ascent
      :auto -> fm_width + ascent + ascent
      width when is_number(width) and width > 0 -> width
    end
  end

  defp get_height(height, %{font_size: font_size, ascent: ascent}) do
    case height do
      nil -> font_size + ascent
      :auto -> font_size + ascent
      height when is_number(height) and height > 0 -> height
    end
  end

  def get_font_metrics(text, font_size) do
    font_size = font_size || @default_font_size
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
