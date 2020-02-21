defmodule LayoutOMatic.PrimitiveLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Circle
  alias LayoutOMatic.Rectangle
  alias LayoutOMatic.RoundedRectangle

  import Scenic.Primitives

  defmodule Layout do
    defstruct primitive: %Scenic.Primitive{},
              starting_xy: {},
              max_xy: {},
              grid_xy: {},
              graph: %{}
  end

  @spec auto_layout(Scenic.Graph.t(), atom, [atom]) :: {:ok, Scenic.Graph.t()}
  def auto_layout(graph, group_id, list_of_prim_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_")
      |> hd()
      |> String.to_atom()

    [%{transforms: %{translate: grid_xy}}] = Graph.get(graph, group_id)
    [%{data: max_xy}] = Graph.get(graph, rect_id)

    graph =
      Enum.reduce(list_of_prim_ids, [], fn p_id, acc ->
        [%{module: module} = primitive] = Graph.get(graph, p_id)

        layout =
          case acc do
            [] ->
              %Layout{
                primitive: primitive,
                starting_xy: grid_xy,
                max_xy: max_xy,
                grid_xy: grid_xy,
                graph: graph
              }

            _ ->
              acc
          end

        do_layout(module, layout, p_id)
      end)
      |> Map.get(:graph)

    {:ok, graph}
  end

  @doc false
  defp do_layout(Scenic.Primitive.Arc, _layout, _p_id), do: nil

  @doc false
  defp do_layout(Scenic.Primitive.Circle, layout, p_id) do
    case Circle.translate(layout) do
      {:ok, xy, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), p_id, &update_opts(&1, t: xy))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc false
  defp do_layout(Scenic.Primitive.Rectangle, layout, p_id) do
    case Rectangle.translate(layout) do
      {:ok, xy, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), p_id, &update_opts(&1, t: xy))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc false
  defp do_layout(Scenic.Primitive.RoundedRectangle, layout, p_id) do
    case RoundedRectangle.translate(layout) do
      {:ok, xy, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), p_id, &update_opts(&1, t: xy))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Primitive.Line, _layout, _p_id), do: nil
  defp do_layout(Scenic.Primitive.Path, _layout, _p_id), do: nil
  defp do_layout(Scenic.Primitive.Quad, _layout, _p_id), do: nil
  defp do_layout(Scenic.Primitive.Sector, _layout, _p_id), do: nil

  defp do_layout(Scenic.Primitive.Triangle, _layout, _p_id) do
    nil
  end

  defp do_layout(_, _, _), do: {:error, "Must be a primitive to auto-layout"}
end
