defmodule Scenic.Layouts.AutoLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Layouts.Circle

  import Scenic.Primitives

  def layout(graph, group_id, list_of_prim_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_")
      |> hd()
      |> String.to_atom()

    [%{transforms: %{translate: starting_xy}}] = Graph.get(graph, group_id)
    [%{data: max_xy}] = Graph.get(graph, rect_id)

    graph =
      Enum.reduce(list_of_prim_ids, [], fn p_id, acc ->
        [%{module: module} = primitive] = Graph.get(graph, p_id)
        {starting_xy, graph} =
          case acc do
            [] ->
              {starting_xy, graph}

            _ ->
              {elem(acc, 0), elem(acc, 1)}
          end

        case module do
          Scenic.Primitive.Arc ->
            nil

          Scenic.Primitive.Circle ->
            case Circle.translate(primitive, max_xy, starting_xy) do
              {:ok, xy} ->
                new_graph = Graph.modify(graph, p_id, &update_opts(&1, t: xy))
                {xy, new_graph}

              {:error, error} ->
                {:error, error}
            end

          Scenic.Primitive.Rect ->
            nil

          Scenic.Primitive.RRect ->
            nil

          Scenic.Primitive.Line ->
            nil

          Scenic.Primitive.Path ->
            nil

          Scenic.Primitive.Quad ->
            nil

          Scenic.Primitive.Sector ->
            nil

          Scenic.Primitive.Triangle ->
            nil

          _ ->
            {:error, "Must be a primitive to auto-layout"}
        end
      end)
      |> elem(1)

    {:ok, graph}
  end
end
