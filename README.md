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
  alias LayoutOMatic.Layouts.Grid
  alias LayoutOMatic.Layouts.Components.AutoLayout

  @viewport Application.get_env(:my_app, :viewport)
            |> Map.get(:size)

  @grid %{
    grid_template: [{:equal, 2}],
    max_xy: @viewport,
    grid_ids: [:left, :right],
    starting_xy: {0, 0},
    opts: [draw: true]
  }

  @graph Graph.build()
         |> Scenic.Primitives.add_specs_to_graph(Grid.grid(@grid),
           id: :root_grid
         )

  def init(_, opts) do
    id_list = [
      :this_toggle,
      :that_toggle,
      :other_toggle,
      :another_toggle
    ]

    graph =
      Enum.reduce(id_list, @graph, fn id, graph ->
        graph
        |> Scenic.Components.toggle(false, id: id)
      end)

    {:ok, new_graph} = AutoLayout.auto_layout(graph, :left_group, id_list)
    {:ok, opts, push: new_graph}
  end
end
```
`AutoLayout.auto_layout/3` and `Primitive.auto_layout/3` are the two functions you will use. They each take a graph, the `group_id` you want to apply the objects to, and a list of ids(which can be used later to easily access those objects). Simply replace your list of ids and the component or primitive you want generated and watch the Layout-O-Matic do all the work for you.

## Supported Primitives
* Circle
* Rectangle
* RoundedRectangle

## Supported Components
All but RadioGroups. Still need to figure those out.

## Transforms
Currently if an object is rotated, the Layout-O-Matic will not respect that as it will likely impact the size of the object.

## Motivation
Scenic is a very exciting framework for the Elixir community especially for embedded applications. The motivation for this project is not to bring the web to Scenic but rather to bring some of the familiar layout apis to Scenic. When I started a project I was quickly frustrated in dynamically placing buttons in a view. This library is to bring some familiar tooling for layouts to Scenic.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. If there is a CSS-like property you believe would be a useful addition please first use the library to make sure it isn't already possible. After, open an issue to discuss it's purpose and why it would be valueable for Scenic development. As Scenic is not for web development, ideally this library would only include the most valuable tools to build great applications.

Please make sure to update tests as appropriate.
