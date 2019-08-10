defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Grid
  alias Scenic.Layouts.Grid.GridBuilder
  alias Scenic.Layouts.AutoLayout

  import Scenic.Primitives

  @viewport :scenic_layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %GridBuilder{
    grid_template: [{2, "equal"}],
    max_xy: @viewport,
    grid_ids: [:left, :right],
    starting_xy: {0, 0}
  }

  @graph Graph.build()
         |> add_specs_to_graph(Grid.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    list = [:this_circle, :that_circle, :other_circle, :another_circle]
    graph =
      Enum.map(list, fn id ->
        @graph |> circle(50, stroke: {4, :white})
      end)
      |> AutoLayout.auto_layout(:left, list)

    {:ok, opts, push: graph}
  end
end
