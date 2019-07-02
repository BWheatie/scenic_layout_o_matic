defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Layout

  import Scenic.Primitives
  # import Scenic.Components
  @graph Graph.build()

  def init(_, _opts) do
    list =
      Enum.map(Layout.grid(5), fn t ->
        group_spec(&(&1), translate: t)
      end)

    graph =
      add_specs_to_graph(@graph, list)

    {:ok, graph, push: graph}
  end
end
