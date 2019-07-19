defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Layout
  alias Scenic.Layouts.Layout.Grid

  import Scenic.Primitives

  @viewport :scenic_layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %Grid{
    equal_layout: 3,
    max_xy: @viewport,
    grid_ids: [:left, :center, :right],
    starting_xy: {0, 0}
  }

  @graph Graph.build()
         |> add_specs_to_graph(Layout.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    IO.inspect(@graph)
    # circle_list = Enum.map(1..4, fn _ ->
    #   circle_spec(10, stroke: {4, :white})
    # end)
    # Graph.add_to(@graph, :relative_grid_group, Layout.auto_layout(:relative_grid_group, circle_list))
    {:ok, opts, push: @graph}
  end
end
