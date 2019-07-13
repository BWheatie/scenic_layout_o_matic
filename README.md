This library will help when wanting some web-like layouts for Scenic framework. Currently it will create something remenicent of a grid by dividing the viewport into equal columns. Once these columns are created they include groups which can be modified to then add new primitives/components to. Currently the grid is in development with auto-layouts, including component resizing, and custom column sizes. 

## Example
```elixir
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
          Layout.grid(2, @viewport, [no_draw: false, group_ids: [:left, :right]]),
          t: {0, 0},
          id: :root_grid)

  def init(_, opts) do
    {:ok, opts, push: @graph}
  end
end
```

`Scenic.Layouts.Layout.grid/3` is how you would set your grids which at this time are really just column markers. At its most basic it takes a number of columns you want calculated. Beyond that you can pass in an {x, y} you want to build within, which could be useful for grids in child elements or if you just don't want the whole viewport to be used. The last arg is a keyword list of options including:

* `group_ids`: this is a list of ids that will be applied, in order, to a group containing a scissored rect and text. These can be used in development to visualize where the columns are and what their ids are.

* `no_draw`: set this to false and the columns as well as column ids will be rendered in the viewport.

![Drawn View](/drawn_view.png)
