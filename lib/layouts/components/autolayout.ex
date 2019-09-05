defmodule Scenic.Layouts.Components.AutoLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Layouts.Components.Button
  alias LayoutOMatic.Layouts.Components.Slider

  import Scenic.Primitives

  def auto_layout(graph, group_id, list_of_comp_ids) do
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
              {:ok, {x, y}, {w, _}} ->
                new_graph = Graph.modify(graph, c_id, &update_opts(&1, t: {x, y}))
                {{x + w, y}, new_graph}

              {:error, error} ->
                {:error, error}
            end

          Scenic.Component.Checkbox ->
            nil
            ## TODO: First determine if there is text: if there is,
            # case Checkbox.translate(component, max_xy, starting_xy, grid_xy) do
            #   {:ok, {x, y}, {w, h}} ->
            #     new_graph = Graph.modify(graph, c_id, &update_opts(&1, t: {x, y}))
            #     {{x + w, y}, new_graph}

            #   {:error, error} ->
            #     {:error, error}
            # end

          Scenic.Component.Dropdown ->
            nil

          Scenic.Component.RadioGroup ->
            nil

          Scenic.Component.Slider ->
            case Slider.translate(component, max_xy, starting_xy, grid_xy) do
              {:ok, {x, y}, {w, h}} ->
                new_graph = Graph.modify(graph, c_id, &update_opts(&1, t: {x, y}))
                {{x + w, y}, new_graph}

              {:error, error} ->
                {:error, error}
            end

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
