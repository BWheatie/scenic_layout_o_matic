# Layout-O-Matic

The Layout-O-Matic slices and dices your viewport in 2 easy steps. With the Layout-O-Matic getting web-like layouts is such a breeze. 

## Installation

```elixir
{:scenic_layout_o_matic, git: "https://github.com/BWheatie/layout_o_matic", tag: "0.1.0"}
```

## Usage
Currently there are two different grid types: equal sized grids and percentage sized grids. The only difference is the key passed to `Layout.grid()/1`.
For equally sized columns you would use `number_of_columns` which takes and `int`. For columns a percentage of the viewport you would use `percentages_of_viewport_x`. Using either key will generate a `group_spec` with `id: <GRID_ID>_group` and a `rect_spec` with `id: <GRID_ID>`. This will make adding new primitives/components to your grid simple by using `Graph.modify/3` passing in either the `group` id or `rect` id depending on what you need. The `rect` has a scissor set for the `{x, y}` of the primitive meaning anything rendered outside of that rect will be scissored. 
### Example
```elixir
defmodule MyApp.Scene.Home do
  use Scenic.Scene
  
  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %Grid{
    percentages_of_viewport_x: [25, 25, 50],
    max_xy: @viewport,
    grid_ids: [:left, :center, :right],
    starting_xy: {0, 0}
   }

  @graph Graph.build()
         |> add_specs_to_graph(Layout.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    {:ok, opts, push: @graph}
  end
end
```

This will output a drawn grid.
!(drawn_grid)[/drawn_view.png]
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
