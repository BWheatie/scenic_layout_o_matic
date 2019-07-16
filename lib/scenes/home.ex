defmodule LayoutOMatic.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Layout

  import Scenic.Primitives

  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %GridEqual{number_of_columns: 3, max_xy: @viewport, grid_ids: [:left, :right, :center]}

  @graph Graph.build()
         |> add_specs_to_graph(
          Layout.grid(@grid),
          t: {0, 0},
          id: :root_grid)

  def init(_, opts) do
    {:ok, opts, push: @graph}
  end
end
