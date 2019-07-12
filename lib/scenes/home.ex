defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Layout

  import Scenic.Primitives

  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @graph Graph.build()
         |> add_specs_to_graph(
          Layout.grid(2, @viewport, [group_ids: [:left, :right]]),
          t: {0, 0},
          id: :root_grid)

  def init(_, opts) do
    IO.inspect(@graph)
    # Layout.auto_layout(@graph, :root_grid, [])
    {:ok, opts, push: @graph}
  end
end
