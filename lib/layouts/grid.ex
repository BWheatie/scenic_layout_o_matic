defmodule LayoutOMatic.Grid do
  import Scenic.Primitives

  alias Scenic.Graph

  @updatable_opts [:translate, :stroke, :hidden]
  @moduledoc """
  Add a grid to a viewport.

  Grids allow you to segment a viewport much like a CSS grid. This allows for
  clear and symantic layouts. Creating a grid is as simple as passing a
  %GridBuilder{} with some values and your viewport will have a grid ready to
  be used.

  ## Data
  * `:viewport` - The viewport struct you want a grid drawn to.
  * `:grid_template` - The type and size of columns for the grid. *Required field*.
    * `{:equal, number_of_equal_columns}` - Indicates columns will be equally sized and how many of them to be drawn
    * `{:percent, percentage_of_viewport}` - Indicates columns will be a percentage of the viewport and what percentage of the viewport. This option is a list of percentages which cannot exceed 100%.
    * `{:relative, percentage_relative_to_object}` - Indicates columns will be drawn relative to another object. This could be used to draw a grid relative to another primitive of component as well as another grid.
  * `:max_xy` - The maximum {x,y} the grid should fit into. This will likely be the viewport size in an inital graph. Default `{700, 600}`. This is the default viewport size for a new scenic app.
  * `:starting_xy` - The {x,y} the grid should start at. Default is {0, 0}.
  * `:grid_ids` - The ids used for each segment of the grid in order to recall the segment later in order to assign a list of objects to it for layouts. Symantically named ids is recommneded. *Required field*
  * `:opts` - A list of additional options
    * `:draw` - Boolean to determine if the grid should be drawn or not. Useful for making sure objects are falling where expected. Default is `false`.

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
  map with the following keys representing where to start the grid, where
  to end the grid, grid_ids, and opts.
  """

  defmodule Error do
    @moduledoc false
    defexception message: nil, data: nil
  end

  defmodule GridBuilder do
    defstruct [
      :viewport,
      :max_xy,
      :starting_xy,
      :grid_ids,
      :column_sizes,
      :opts
    ]
  end

  @doc """
  A simple grid is the most basic type. It creates a grid with a top, bottom, left, right, center. All that is needed is the starting and max points.
  The resulting grid will contain rects and groups per portion of grid with center being the exception. Center is simple a point which can be referrenced.
  Note grids are primitives specs so to add them to the graph you will need to use `add_specs_to_graph/2`.

  * `:starting_xy` - The {x,y} the grid should start at.
  * `:max_xy` - The maximum {x,y} the grid should fit into. This can be the full viewport of a subset of the viewport like another grid you are adding to.
  * `:grid_ids` - List of atoms representing the ids to be added. These ids will be applied in a clockwise way. *Note:* it is important to use unique ids unless
  the intention is to have similar components to be modified, deleted together. If this does not sound like what you want, be sure to use unique ids.
  * `:opts` - A list of additional options
    * `:draw` - Boolean to determine if the grid should be drawn or not. Useful for making sure objects are falling where expected.
    * `:grid_ids` - The ids used for each segment of the grid in order to recall the segment later in order to assign a list of objects to it for layouts. Symantically named ids is recommneded.

  ```elixir
  def init(_, opts) do
    grid = Graph.build()
    |> add_specs_to_graph(Grid.simple({0, 0}, {700, 600}, [:top, :right, :bottom, :left, :center]))
    {:ok, opts, push: graph}
  end
  ```
  """
  @spec simple({number, number}, {number, number}, [any]) :: [{number, number}]
  def simple({starting_x, starting_y} = starting_xy, {max_x, max_y}, grid_ids, opts \\ []) do
    top_bottom_size = {max_x, max_y / 2}
    top = {top_bottom_size, starting_xy}
    bottom = {top_bottom_size, {starting_x, max_y / 2}}

    left_right_size = {max_x / 2, max_y}
    left = {left_right_size, starting_xy}
    right = {left_right_size, {max_x / 2, starting_y}}

    # center should just be a point and the rect should ultimately do nothing.
    center = {starting_xy, {elem(left_right_size, 0), elem(top_bottom_size, 1)}}

    grid = [
      {Enum.fetch!(grid_ids, 0), top},
      {Enum.fetch!(grid_ids, 1), right},
      {Enum.fetch!(grid_ids, 2), bottom},
      {Enum.fetch!(grid_ids, 3), left},
      {Enum.fetch!(grid_ids, 4), center}
    ]

    Enum.map(grid, fn {id, coords} ->
      draw_grid(coords, id, opts[:draw])
    end)
  end

  @doc """
  A percentage grid is one where the grid portions are percentages o the overall grid area. Like a simple grid, percentages take a starting and max point but also
  take a list of percentages representing the grid portions from left to right. Note the returned grid will be a list of primitive specs so you will need to use
  `add_specs_to_graph/2`.

  ```elixir
  Grid.percentage({0, 0}, {700, 600}, [25, 50, 25], [:left, :center, :right], [draw: true])
  ```
  """
  @spec percentage({number, number}, {number, number}, [any], [atom]) :: [
          Scenic.Primitives.Group.t()
        ]
  def percentage(
        {starting_x, _} = starting_xy,
        {max_x, _} = max_xy,
        percentages,
        grid_ids,
        opts \\ []
      )
      when is_list(percentages) and is_list(grid_ids) do
    column_sizes =
      Enum.map(percentages, fn p ->
        p / 100 * max_x - starting_x
      end)

    %{
      starting_xy: starting_xy,
      max_xy: max_xy,
      column_sizes: column_sizes,
      grid_ids: grid_ids,
      opts: opts
    }
    |> get_x_coordinates()
  end

  @doc """
  A pixel grid is identical to a percentatge grid with the difference being that instead of a list of numbers representing percentages, that list represents pixels.
  Like a simple grid, pixel take a starting and max point but also take a list of numbers representing the grid portions in pixel from left to right. Note the
  returned grid will be a list of primitive specs so you will need to use `add_specs_to_graph/2`.

  ```elixir
  Grid.pixel({0, 0}, {700, 600}, [50, 150, 25], [:left_nav, :content, :side_bar], [draw: true])
  ```
  """

  @spec pixel({number, number}, {number, number}, [number], [atom], []) :: [
          Scenic.Primitives.Group.t()
        ]
  def pixel(starting_xy, max_xy, [] = sizes, [] = grid_ids, opts \\ [])
      when is_list(sizes) and is_list(grid_ids) do
    %{
      starting_xy: starting_xy,
      max_xy: max_xy,
      column_sizes: sizes,
      grid_ids: grid_ids,
      opts: opts
    }
    |> get_x_coordinates()
  end

  @doc """
  An equal grid is much like a pixel grid but instead of determined sizes, it takes a number representing the equal number of portions to be created.
  Like a simple grid, equal take a starting and max point but also take a number representing the equally sized grid portions from left to right. Note the
  returned grid will be a list of primitive specs so you will need to use `add_specs_to_graph/2`.

  ```elixir
  Grid.equal({0, 0}, {700, 600}, 4, [:left, :left_center, :right_center, :right], [draw: true])
  ```
  """

  @spec equal({number, number}, {number, number}, number, [atom], []) :: [
          Scenic.Primitives.Group.t()
        ]
  def equal(starting_xy, {max_x, _} = max_xy, number_of_portions, grid_ids, opts \\ [])
      when is_list(grid_ids) do
    column_sizes = div(max_x, number_of_portions)

    %{
      starting_xy: starting_xy,
      max_xy: max_xy,
      column_sizes: [column_sizes, column_sizes],
      grid_ids: grid_ids,
      opts: opts
    }
    |> get_x_coordinates()
  end

  @doc """
  A pixel grid is identical to a percentatge grid with the difference being that instead of a list of numbers representing percentages, that list represents pixels.
  Like a simple grid, pixel take a starting and max point but also take a list of numbers representing the grid portions in pixel from left to right. Note the
  returned grid will be a list of primitive specs so you will need to use `add_specs_to_graph/2`.

  ```elixir
  Grid.pixel({0, 0}, {700, 600}, [50, 150, 25], [:left_nav, :content, :side_bar], [draw: true])
  ```
  """

  @spec pixel({number, number}, {number, number}, [number], [atom], []) :: [
          Scenic.Primitives.Group.t()
        ]
  def pixel(starting_xy, max_xy, [] = sizes, [] = grid_ids, opts \\ [])
      when is_list(sizes) and is_list(grid_ids) do
    %{
      starting_xy: starting_xy,
      max_xy: max_xy,
      column_sizes: sizes,
      grid_ids: grid_ids,
      opts: opts
    }
    |> get_x_coordinates()
  end

  @doc """
  An equal grid is much like a pixel grid but instead of determined sizes, it takes a number representing the equal number of portions to be created.
  Like a simple grid, equal take a starting and max point but also take a number representing the equally sized grid portions from left to right. Note the
  returned grid will be a list of primitive specs so you will need to use `add_specs_to_graph/2`.

  ```elixir
  Grid.equal({0, 0}, {700, 600}, 4, [:left, :left_center, :right_center, :right], [draw: true])
  ```
  """

  @spec equal({number, number}, {number, number}, number, [atom], []) :: [
          Scenic.Primitives.Group.t()
        ]
  def equal(starting_xy, {max_x, _} = max_xy, number_of_portions, grid_ids, opts \\ [])
      when is_list(grid_ids) do
    column_sizes = div(max_x, number_of_portions)

    %{
      starting_xy: starting_xy,
      max_xy: max_xy,
      column_sizes: [column_sizes, column_sizes],
      grid_ids: grid_ids,
      opts: opts
    }
    |> get_x_coordinates()
  end

  # idea is to be able to recursively iterate through an unknown depth graph to get groups and primitives
  # def update_grid(graph, id, opts) do
  # end

  # def update_grid(graph, grid_id, opts) when is_atom(grid_id) do
  #   [%{data: children}] = Graph.get(graph, grid_id)
  #   process_children(graph, children, opts)
  # end

  # defp process_children(graph, children, opts) do
  #   Enum.reduce(children, {[], graph}, fn c, {prev_children, acc_graph} ->
  #     case Graph.get_by_uid(graph, c) do
  #       %{module: Scenic.Primitive.Group, data: children} ->
  #         {children ++ prev_children, acc_graph}

  #       primitive ->
  #         this_graph =
  #           acc_graph
  #           |> Graph.modify(primitive, fn p ->
  #             update_opts(p, opts)
  #           end)

  #         {children, this_graph}
  #     end
  #   end)
  #   |> case do
  #     {[_ | _] = children, new_graph} ->
  #       process_children(new_graph, children, opts)

  #     {[], new_graph} ->
  #       new_graph
  #   end
  # end

  @doc false
  defp get_x_coordinates(grid) do
    ids_and_sizes = Enum.zip(Map.get(grid, :grid_ids), Map.get(grid, :column_sizes))
    opts = Map.get(grid, :opts)

    Enum.map_reduce(ids_and_sizes, [], fn i, acc ->
      starting_xy = Map.get(grid, :starting_xy)
      {_, max_y} = Map.get(grid, :max_xy)

      case acc do
        [] ->
          {draw_grid(max_y, elem(i, 1), starting_xy, elem(i, 0), opts[:draw]),
           elem(starting_xy, 0) + elem(i, 1)}

        _ ->
          {draw_grid(max_y, elem(i, 1), {acc, elem(starting_xy, 1)}, elem(i, 0), opts[:draw]),
           acc + elem(i, 1)}
      end
    end)
    |> elem(0)
  end

  @doc false
  defp draw_grid({size, translate}, id, draw) do
    group_spec(
      rect_spec(size,
        stroke: {1, :black},
        scissor: size,
        id: id,
        hidden: !draw
      ),
      id: String.to_atom(Atom.to_string(id) <> "_group"),
      t: translate
    )
  end

  @doc false
  defp draw_grid(max_y, size, starting_xy, id, draw) do
    group_spec(
      rect_spec({size, max_y},
        stroke: {1, :black},
        scissor: {size, max_y},
        id: id,
        hidden: !draw
      ),
      id: String.to_atom(Atom.to_string(id) <> "_group"),
      t: {elem(starting_xy, 0), elem(starting_xy, 1)}
    )
  end
end
