# Layout-O-Matic

The Layout-O-Matic slices and dices your viewport in 2 easy steps. With the Layout-O-Matic getting web-like layouts is such a breeze.

Layout Engine for [Scenic Framework](https://github.com/boydm/scenic)
([documentation](http://hexdocs.pm/scenic_layout_o_matic/)).

## Installation

```elixir
{:scenic_layout_o_matic, "0.1.0"}
```

## Usage

```elixir
defmodule MyApp.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Layouts.Grid
  alias Scenic.Layouts.Grid.GridBuilder
  alias Scenic.Layouts.Components.AutoLayout, as: Component

  import Scenic.Components


  @viewport :layout_o_matic
            |> Application.get_env(:viewport)
            |> Map.get(:size)

  @grid %GridBuilder{
    grid_template: [{:equal, 2}],
    max_xy: @viewport,
    grid_ids: [:left, :right],
    starting_xy: {0, 0},
    opts: [draw: true]
  }

  @graph Graph.build()
         |> add_specs_to_graph(Grid.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    list = [
      :this_toggle,
      :that_toggle,
      :other_toggle,
      :another_toggle
    ]

    graph =
      Enum.reduce(list, @graph, fn id, acc ->
        acc |> toggle(false, id: id)
      end)

    {:ok, new_graph} = Component.auto_layout(graph, :left_group, list)
    {:ok, opts, push: new_graph}
  end
end
```

Simply replace your list of ids and the component or primitive you want generated and watch the Layout-O-Matic do all the work for you.

## Supported Primitives
* Circle
* Rectangle
* RoundedRectangle

## Supported Components
All but RadioGroups. Still need to figure those out.


## Motivation
Scenic is a very exciting framework for the Elixir community especially for embedded applications. The motivation for this project is not to bring the web to Scenic but rather to bring some of the familiar layout apis to Scenic. When I started a project I was quickly frustrated in dynamically placing buttons in a view. This library is to bring some familiar tooling for layouts to Scenic.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
