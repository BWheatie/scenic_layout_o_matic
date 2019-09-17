defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Grid
  alias Scenic.Layouts.Grid.GridBuilder
  alias Scenic.Layouts.Primitives.AutoLayout, as: Primitive
  alias Scenic.Layouts.Components.AutoLayout, as: Component

  import Scenic.Primitives
  import Scenic.Components

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
    # IO.inspect(opts[:viewport])
    # list = [:this_button, :that_button, :other_button, :another_button]

    # graph =
    #   Enum.reduce(list, @graph, fn id, acc ->
    #     # acc |> circle(50, id: id, stroke: {4, :white})
    #     acc |> button("BUTTON", id: id, width: 200, height: 70)
    #   end)

    # # new_graph = button("BUTTON", id: id, width: 90, height: 70)
    # {:ok, new_graph} = Component.auto_layout(graph, :left_group, list)
    IO.inspect(@graph)
    {:ok, opts, push: @graph}
  end
end
