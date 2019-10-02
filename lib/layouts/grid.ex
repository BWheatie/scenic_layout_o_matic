defmodule Scenic.Layouts.Grid do
  import Scenic.Primitives

  @moduledoc """
  Add a grid to a viewport.

  Grids allow you to segment a viewport much like a CSS grid. This allows for
  clear and symantic layouts. Creating a grid is as simple as passing a
  %GridBuilder{} with some values and your viewport will have a grid ready to
  be used.

  ## Data
  * `:viewport` - The viewport struct you want a grid drawn to.
  * `:grid_template` - The type and size of columns for the grid.
    * `{:equal, number_of_equal_columns}` - Indicates columns will be equally sized and how many of them to be drawn
    * `{:percentage, percentage_of_viewport}` - Indicates columns will be a percentage of the viewport and what percentage of the viewport. This option is a list of percentages which cannot exceed 100%.
    * `{:relative, percentage_relative_to_object}` - Indicates columns will be drawn relative to another object. This could be used to draw a grid relative to another primitive of component as well as another grid.
  * `:max_xy` - The maximum {x,y} the grid should fit into. This will likely be the viewport size in an inital graph.
  * `:starting_xy` - The {x,y} the grid should start at. In an inital grid it will be {0,0}.
  * `:grid_ids` - The ids used for each segment of the grid in order to recall the segment later in order to assign a list of objects to it for layouts. Symantically named ids is recommneded.
  * `:opts` - A list of additional options
    * `:draw` - Boolean to determine if the grid should be drawn or not. Useful for making sure objects are falling where expected.

  ```
  @viewport :scenic_layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %GridBuilder{
    grid_template: [{:equal, 2}],
    max_xy: @viewport,
    grid_ids: [:left, :right],
    starting_xy: {0, 0}
  }

  @graph Graph.build()
         |> add_specs_to_graph(Grid.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    {:ok, opts, push: @graph}
  end
  """

  defmodule Error do
    @moduledoc false
    defexception message: nil, data: nil
  end

  defmodule GridBuilder do
    @enforce_keys [:grid_template, :grid_ids]
    defstruct viewport: %{},
              grid_template: [{:equal, 1}],
              # This should come off the viewport map passed in.
              max_xy: {700, 600},
              starting_xy: {0, 0},
              grid_ids: nil,
              column_sizes: nil,
              opts: [draw: false]
  end

  def grid(%GridBuilder{} = grid) do
    {starting_x, _} = Map.get(grid, :starting_xy)
    {max_x, _} = Map.get(grid, :max_xy)

    column_sizes =
      Enum.map(Map.get(grid, :grid_template), fn t ->
        case elem(t, 0) do
          :percent ->
            trunc(elem(t, 0) / 100 * max_x - starting_x)

          :equal ->
            Enum.map(1..elem(t, 1), fn _ ->
              div(max_x, elem(t, 1))
            end)

          :relative ->
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

  @moduledoc false
  defp get_x_coordinates(grid) do
    ids_and_sizes = Enum.zip(Map.get(grid, :grid_ids), Map.get(grid, :column_sizes))
    opts = Map.get(grid, :opts)

    Enum.map_reduce(ids_and_sizes, [], fn i, acc ->
      starting_xy = Map.get(grid, :starting_xy)
      {_, max_y} = Map.get(grid, :max_xy)

      case acc do
        [] ->
          {build_grid(max_y, elem(i, 1), starting_xy, elem(i, 0), opts[:draw]),
           elem(starting_xy, 0) + elem(i, 1)}

        _ ->
          {build_grid(max_y, elem(i, 1), {acc, elem(starting_xy, 1)}, elem(i, 0), opts[:draw]),
           acc + elem(i, 1)}
      end
    end)
    |> elem(0)
  end

  @moduledoc false
  defp build_grid(max_y, size, starting_xy, id, draw) do
    group_spec(
      rect_spec({size, max_y},
        stroke: {1, :white},
        scissor: {size, max_y},
        hidden: !draw,
        id: id
      ),
      id: String.to_atom(Atom.to_string(id) <> "_group"),
      t: {elem(starting_xy, 0), elem(starting_xy, 1)}
    )
  end
end
