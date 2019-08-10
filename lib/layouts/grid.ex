defmodule Scenic.Layouts.Grid do
  import Scenic.Primitives

  defmodule Error do
    @moduledoc false
    defexception message: nil, data: nil
  end

  # Relative units? grid relative to another grid thereby relative to the group.
  defmodule GridBuilder do
    @enforce_keys [:grid_template, :grid_ids]
    defstruct viewport: %{},
      grid_template: [{1, "equal"}],
      max_xy: {700, 600},
      starting_xy: {0, 0},
      grid_ids: nil,
      column_sizes: nil,
      opts: [draw: true]
  end

  def grid(%GridBuilder{} = grid) do
    {starting_x, _} = Map.get(grid, :starting_xy)
    {max_x, _} = Map.get(grid, :max_xy)

    column_sizes =
      Enum.map(Map.get(grid, :grid_template), fn t ->
        case elem(t, 1) do
          "percent" ->
            trunc(elem(t, 0) / 100 * max_x - starting_x)

          "equal" ->
            Enum.map(1..elem(t, 0), fn _ ->
              div(max_x, elem(t, 0))
            end)

          "relative" ->
            trunc(elem(t, 0) / 100 * max_x)
        end
      end)

    Map.put(
      grid,
      :column_sizes,
      List.flatten(column_sizes)
    )
    |> get_x_coordinates()
  end

  def get_x_coordinates(grid) do
    IO.inspect(grid)
    ids_and_sizes = Enum.zip(Map.get(grid, :grid_ids), Map.get(grid, :column_sizes))
    hidden = Map.get(grid, :hidden)

    Enum.map_reduce(ids_and_sizes, [], fn i, acc ->
      starting_xy = Map.get(grid, :starting_xy)
      {_, max_y} = Map.get(grid, :max_xy)

      case acc do
        [] ->
          {build_grid(max_y, elem(i, 1), starting_xy, elem(i, 0), hidden),
           elem(starting_xy, 0) + elem(i, 1)}

        _ ->
          {build_grid(max_y, elem(i, 1), {acc, elem(starting_xy, 1)}, elem(i, 0), hidden),
           acc + elem(i, 1)}
      end
    end)
    |> elem(0)
  end

  def build_grid(max_y, size, starting_xy, id, hidden) do
    group_spec(
      rect_spec({size, max_y},
        stroke: {1, :white},
        scissor: {size, max_y},
        hidden: !hidden,
        id: id
      ),
      id: String.to_atom(Atom.to_string(id) <> "_group"),
      t: {elem(starting_xy, 0), elem(starting_xy, 1)}
    )
  end
end
