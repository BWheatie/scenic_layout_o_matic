defmodule Scenic.Layouts.Components.AutoLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Layouts.Components.Button

  import Scenic.Primitives

  def layout(graph, group_id, list_of_comp_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_")
      |> hd()
      |> String.to_atom()

    [%{transforms: %{translate: grid_xy}}] = Graph.get(graph, group_id)
    [%{data: max_xy}] = Graph.get(graph, rect_id)

    graph =
      Enum.reduce(list_of_comp_ids, [], fn c_id, acc ->
        [%{data: {comp, _}} = component] = Graph.get(graph, c_id)

        {starting_xy, graph} =
          case acc do
            [] ->
              {grid_xy, graph}

            _ ->
              acc
          end

        case comp do
          Scenic.Component.Button ->
            case Button.translate(component, max_xy, starting_xy, grid_xy) do
              {:ok, {x, y}, {w, h}} ->
                new_graph = Graph.modify(graph, c_id, &update_opts(&1, t: {x, y}))
                {{x + w, y}, new_graph}

              {:error, error} ->
                {:error, error}
            end

          Scenic.Component.Checkbox ->
            nil

          Scenic.Component.Dropdown ->
            nil

          Scenic.Component.RadioGroup ->
            nil

          Scenic.Component.Slider ->
            nil

          Scenic.Component.TextField ->
            nil

          Scenic.Component.Toggle ->
            nil
        end
      end)
      |> elem(1)

    {:ok, graph}
  end
end
