defmodule Scenic.Layouts.Primitives.AutoLayout do
  alias Scenic.Graph
  alias LayoutOMatic.Layouts.Primitives.Circle
  alias LayoutOMatic.Layouts.Primitives.Rectangle
  alias LayoutOMatic.Layouts.Primitives.RoundedRectangle
  # alias LayoutOMatic.Layouts.Primitives.Triangle

  import Scenic.Primitives

  defmodule Layout do
    defstruct component: %Scenic.Primitive{},
              starting_xy: {},
              max_xy: {},
              grid_xy: {},
              graph: %{}
  end

  def layout(graph, group_id, list_of_prim_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_")
      |> hd()
      |> String.to_atom()

    [%{transforms: %{translate: grid_xy}}] = Graph.get(graph, group_id)
    [%{data: max_xy}] = Graph.get(graph, rect_id) |> IO.inspect()

    graph =
      Enum.reduce(list_of_prim_ids, [], fn p_id, acc ->
        [%{module: module} = primitive] = Graph.get(graph, p_id)

        {starting_xy, graph} =
          case acc do
            [] ->
              {grid_xy, graph}

            _ ->
              acc
          end

        layout = %Layout{
          component: primitive,
          starting_xy: starting_xy,
          max_xy: max_xy,
          grid_xy: grid_xy,
          graph: graph
        }

        do_layout(module, layout, p_id)
      end)
      |> elem(1)

    {:ok, graph}
  end

  defp do_layout(Scenic.Primitive.Arc, _layout, _p_id), do: nil

  defp do_layout(Scenic.Primitive.Circle, layout, p_id) do
    case Circle.translate(
           Map.get(layout, :primitive),
           Map.get(layout, :max_xy),
           Map.get(layout, :starting_xy),
           Map.get(layout, :grid_xy)
         ) do
      {:ok, xy} ->
        new_graph = Graph.modify(Map.get(layout, :graph), p_id, &update_opts(&1, t: xy))
        {xy, new_graph}

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Primitive.Rectangle, layout, p_id) do
    case Rectangle.translate(
           Map.get(layout, :primitive),
           Map.get(layout, :max_xy),
           Map.get(layout, :starting_xy),
           Map.get(layout, :grid_xy)
         ) do
      {:ok, xy} ->
        new_graph = Graph.modify(Map.get(layout, :graph), p_id, &update_opts(&1, t: xy))
        {xy, new_graph}

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Primitive.RoundedRectangle, layout, p_id) do
    case RoundedRectangle.translate(
           Map.get(layout, :primitive),
           Map.get(layout, :max_xy),
           Map.get(layout, :starting_xy),
           Map.get(layout, :grid_xy)
         ) do
      {:ok, xy} ->
        new_graph = Graph.modify(Map.get(layout, :graph), p_id, &update_opts(&1, t: xy))
        {xy, new_graph}

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

    # case Triangle.translate(Map.get(layout, :primitive), Map.get(layout, :max_xy), Map.get(layout, :starting_xy), Map.get(layout, :grid_xy)) do
    #   {:ok, xy} ->
    #     new_graph = Graph.modify(Map.get(layout, :graph), p_id, &update_opts(&1, t: xy))
    #     {xy, new_graph}

    #   {:error, error} ->
    #     {:error, error}
    # end
  end

  defp do_layout(_, _, _), do: {:error, "Must be a primitive to auto-layout"}
end
