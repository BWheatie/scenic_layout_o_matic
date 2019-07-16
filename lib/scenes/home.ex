defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Layout
  alias Scenic.Layouts.Layout.Grid

  import Scenic.Primitives

  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %Grid{number_of_columns: 2, max_xy: @viewport, grid_ids: [:left, :right]}

  @graph Graph.build()
         |> add_specs_to_graph(Layout.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    {:ok, opts, push: @graph}
  end
end
