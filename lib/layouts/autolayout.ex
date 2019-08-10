defmodule Layouts.AutoLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Layouts.Circle

  import Scenic.Primitives
  import LayoutOMatic.Layouts.LayoutGuards

  def auto_layout(graph, group_id, list_of_prim_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_")
      |> hd()

    [%{transforms: %{translate: starting_xy}}] = Graph.get(graph, group_id)
    [%{data: max_xy}] = Graph.get(graph, rect_id)

    Enum.map_reduce(list_of_prim_ids, [], fn p_id, acc ->
      case acc do
        [] ->
          [%{data: size}] = Graph.get(graph, p_id)
          {Graph.modify(graph, rect_id, &update_opts(&1, t: starting_xy)), {starting_xy, size}}

        _ ->
          [%{data: size}] = Graph.get(graph, p_id)
          {starting_xy, _} = List.first(acc)

          case size do
            size when is_arc(size) ->
              nil

            size when is_circle(size) ->
              Graph.modify(
                graph,
                rect_id,
                &update_opts(&1, t: Circle.translate(size, max_xy, starting_xy))
              )

            size when is_rect(size) ->
              nil

            size when is_rrect(size) ->
              nil

            size when is_line(size) ->
              nil

            size when is_path(size) ->
              nil

            size when is_quad(size) ->
              nil

            size when is_sector(size) ->
              nil

            size when is_triangle(size) ->
              nil
          end
      end
    end)
  end
end
