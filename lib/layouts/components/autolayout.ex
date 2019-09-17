defmodule Scenic.Layouts.Components.AutoLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Layouts.Components.Button
  # alias LayoutOMatic.Layouts.Components.Slider

  import Scenic.Primitives

  defmodule Layout do
    defstruct component: %Scenic.Primitive{},
              starting_xy: {},
              max_xy: {},
              grid_xy: {},
              graph: %{},
              padding: [{:total, 1}],
              margin: [{:total, 1}],
              position: :static,
              float: :none,
              align: :none
  end

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
        [%{data: {comp_type, _}} = component] = Graph.get(graph, c_id)

        {starting_xy, graph, %{}} =
          case acc do
            [] ->
              {grid_xy, graph, %{}}

            _ ->
              acc
          end

        layout = %Layout{
          component: component,
          starting_xy: starting_xy,
          max_xy: max_xy,
          grid_xy: grid_xy,
          graph: graph
        }

        do_layout(comp_type, layout, c_id)
      end)
      |> elem(1)

    {:ok, graph}
  end

  def do_layout(Scenic.Component.Button, layout, c_id) do
    case Button.translate(layout) do
      {:ok, {x, y}, {w, _}, layout} ->
        new_graph = Graph.modify(Map.get(layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        {{x + w, y}, new_graph, layout}

      {:error, error} ->
        {:error, error}
    end
  end

  def do_layout(Scenic.Component.Checkbox, _, _) do
    nil
    ## TODO: First determine if there is text: if there is,
    # case Checkbox.translate(component, max_xy, starting_xy, grid_xy) do
    #   {:ok, {x, y}, {w, h}} ->
    #     new_graph = Graph.modify(graph, c_id, &update_opts(&1, t: {x, y}))
    #     {{x + w, y}, new_graph}

    #   {:error, error} ->
    #     {:error, error}
    # end
  end

  def do_layout(Scenic.Component.Dropdown, _, _), do: nil
  def do_layout(Scenic.Component.RadioGroup, _, _), do: nil

  def do_layout(Scenic.Component.Slider, _, _) do
    nil
    # case Slider.translate(component, max_xy, starting_xy, grid_xy) do
    #   {:ok, {x, y}, {w, h}} ->
    #     new_graph = Graph.modify(graph, c_id, &update_opts(&1, t: {x, y}))
    #     {{x + w, y}, new_graph}

    #   {:error, error} ->
    #     {:error, error}
    # end
  end

  def do_layout(Scenic.Component.TextField, _, _), do: nil
  def do_layout(Scenic.Component.Toggle, _, _), do: nil
end
