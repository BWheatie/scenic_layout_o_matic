defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Layout

  import Scenic.Primitives

  @graph Graph.build()

  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  def init(_, _opts) do

    graph =
      add_specs_to_graph(@graph, Layout.grid(5, @viewport, [draw: true]))

    {:ok, graph, push: graph}
  end
end
