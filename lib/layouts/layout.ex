defmodule Scenic.Layouts.Layout do

  @viewport :layout_o_matic
          |> Application.get_env(:viewport)
          |> Map.get(:size)

  def grid(number_of_columns, {starting_x, starting_y} \\ @viewport, _opts \\ nil) do
    size = round(starting_x / number_of_columns)

    list_of_x =
      Enum.map((number_of_columns - 1)..1, fn cols ->
        starting_x - size * cols
      end)

    Enum.map(list_of_x, fn x ->
      {x, 0}
    end)
  end

  # def draw_guides(list_of_x, starting_y) do
  #   Enum.map(list_of_x, fn x ->
  #     line_spec({{x, 0}, {x, starting_y}}, stroke: {0.25, :white})
  #   end)
  # end

end
