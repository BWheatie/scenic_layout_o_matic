defmodule Scenic.Layouts.Grid do
  import Scenic.Primitives

  defmodule Error do
    @moduledoc false
    defexception message: nil, data: nil
  end

  # Relative units? grid relative to another grid thereby relative to the group.
  defmodule GridBuilder do
    @enforce_keys [:max_xy, :grid_ids]
    defstruct [
      :relative_layout,
      :equal_layout,
      :percentage_layout,
      :max_xy,
      :starting_xy,
      :grid_ids,
      :column_sizes,
      opts: [:draw]
    ]
  end

  def grid(%GridBuilder{relative_layout: percent} = grid) when not is_nil(percent) do
    {starting_x, _} = Map.get(grid, :starting_xy)
    {max_x, _} = Map.get(grid, :max_xy)

    Map.put(
      grid,
      :column_sizes,
      Enum.map([percent], fn p ->
        trunc(p / 100 * max_x - starting_x)
      end)
    )
    |> get_x_coordinates()
  end

  def grid(%GridBuilder{equal_layout: num} = grid) when not is_nil(num) do
    {max_x, _} = Map.get(grid, :max_xy)

    Map.put(
      grid,
      :column_sizes,
      Enum.map(1..Map.get(grid, :equal_layout), fn _ ->
        div(max_x, Map.get(grid, :equal_layout))
      end)
    )
    |> get_x_coordinates()
  end

  def grid(%GridBuilder{percentage_layout: percentages} = grid)
      when not is_nil(percentages) and is_list(percentages) do
    case Enum.sum(percentages) do
      sum when sum <= 100 ->
        {max_x, _} = Map.get(grid, :max_xy)

        Map.put(
          grid,
          :column_sizes,
          Enum.map(percentages, fn percent ->
            trunc(percent / 100 * max_x)
          end)
        )
        |> get_x_coordinates()

      _ ->
        raise Error, message: "Percentages cannot be more than 100%", data: percentages
    end
  end

  def get_x_coordinates(grid) do
    ids_and_sizes = Enum.zip(Map.get(grid, :grid_ids), Map.get(grid, :column_sizes))

    Enum.map_reduce(ids_and_sizes, [], fn i, acc ->
      starting_xy = Map.get(grid, :starting_xy)
      {_, max_y} = Map.get(grid, :max_xy)

      case acc do
        [] ->
          {build_grid(max_y, elem(i, 1), starting_xy, elem(i, 0)),
           elem(starting_xy, 0) + elem(i, 1)}

        _ ->
          {build_grid(max_y, elem(i, 1), {acc, elem(starting_xy, 1)}, elem(i, 0)),
           acc + elem(i, 1)}
      end
    end)
    |> elem(0)
  end

  def build_grid(max_y, size, starting_xy, id) do
    group_spec(
      rect_spec({size, max_y},
        stroke: {1, :white},
        scissor: {size, max_y},
        id: id
      ),
      id: String.to_atom(Atom.to_string(id) <> "_group"),
      t: {elem(starting_xy, 0), elem(starting_xy, 1)}
    )
  end
end
