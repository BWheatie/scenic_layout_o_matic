defmodule LayoutOMatic.PrimitiveLayout do
  require Logger

  @typedoc """
  Defines a PrimitiveLayout struct.

  ## Fields
    * `:primitive` - A Scenic Primitive. Used to find the size, styles and transforms for a primitive. Used to calculate translates.
    * `:starting_xy` - {x, y} translate of the previous primtive. Next primtive uses this to start it's translate from.
    * `:grid_xy` - {x, y} translate of the grid to add primitives to. This is the initial starting point to translate a list of primitives.
    * `:graph` - Scenic Graph object. Graph to add primitives to. This is result of the layout functions.
    * `:wrap` - Boolean indicating whether to wrap primitives when they exceed the bounding box.
  """
  @type t :: %__MODULE__{
          primitive: Scenic.Primitive.t(),
          starting_xy: tuple(),
          grid_xy: tuple(),
          bounding_box: tuple(),
          graph: Scenic.Graph.t(),
          padding: number(),
          axis: atom(),
          wrap: boolean()
        }
  defstruct primitive: %{},
            starting_xy: {},
            max_xy: {},
            grid_xy: {},
            bounding_box: {},
            graph: %{},
            padding: 0,
            axis: :x,
            wrap: false

  alias Scenic.Graph
  alias LayoutOMatic.Arc
  alias LayoutOMatic.Circle
  alias LayoutOMatic.Group
  alias LayoutOMatic.Rectangle
  alias LayoutOMatic.RoundedRectangle

  import Scenic.Primitives

  @doc """
  Used to layout a list of primitives within a bounding box. This will reflow the primitives to fit within the bounding box.

  TODO:
  * do not assume there is a group
  * take the rectangle id as an arg
  """
  @spec auto_layout(Scenic.Graph.t(), atom, [atom]) :: {:ok, Scenic.Graph.t()}
  def auto_layout(graph, group_id, list_of_prim_ids) when is_atom(group_id) do
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
              %__MODULE__{
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

  @spec alt_group_auto_layout(
          Scenic.Group.t(),
          {number, number},
          {number, number},
          atom | String.t(),
          Keyword.t()
        ) :: Scenic.Graph.t() | atom
  def alt_group_auto_layout(graph, starting_xy, max_xy, group_ids, opts \\ []) do
    padding = Keyword.get(opts, :padding, 0)

    Enum.reduce(group_ids, [], fn group_id, acc ->
      with %{module: Scenic.Primitive.Group, data: ids} <- Graph.get!(graph, group_id),
           [_ | _] = primitives <- Enum.map(ids, &Map.get(graph.primitives, &1)),
           %{} = primitive <-
             Enum.find(primitives, &(&1.module == Scenic.Primitive.Rectangle)) do
        case acc do
          [] ->
            %__MODULE__{
              primitive: primitive,
              starting_xy: starting_xy,
              max_xy: max_xy,
              grid_xy: starting_xy,
              graph: graph,
              padding: padding
            }

          _ ->
            acc
            |> Map.put(:prev_primitive, acc.primitive)
            |> Map.put(:primitive, primitive)
        end
        |> Rectangle.translate()
        |> case do
          {:ok, xy, new_layout} ->
            new_graph =
              new_layout
              |> Map.get(:graph)
              |> Graph.modify(group_id, &update_opts(&1, t: xy))

            Map.put(new_layout, :graph, new_graph)

          {:error, error} ->
            {:error, error}
        end
      end
    end)
    |> Map.get(:graph)
  end

  @spec group_auto_layout(
          Scenic.Graph.t(),
          {number, number},
          {number, number},
          [
            atom | String.t()
          ],
          Keyword.t()
        ) :: Scenic.Graph.t()
  def group_auto_layout(graph, point, bounding_box, list_of_prim_ids, opts \\ []) do
    graph =
      Enum.reduce(list_of_prim_ids, [], fn p_id, acc ->
        primitive = Graph.get!(graph, p_id)

        layout =
          case acc do
            [] ->
              %__MODULE__{
                primitive: primitive,
                starting_xy: point,
                grid_xy: point,
                bounding_box: bounding_box,
                graph: graph,
                padding: opts[:padding] || 0,
                axis: opts[:axis] || :x,
                wrap: opts[:wrap] || false
              }

            _ ->
              acc
          end

        {:ok, xy, new_layout} = do_from_point_layout(layout)
        new_graph = Graph.modify(Map.get(new_layout, :graph), p_id, &update_opts(&1, t: xy))
        Map.put(new_layout, :graph, new_graph)
      end)
      |> Map.get(:graph)

    graph
  end

  @doc """
  Used to layout a list of primitives using a starting point {x, y} in a line. Does not reflow primitives within a bounding box. Can be a mix of primitives.
  """
  @spec from_point_layout(
          Scenic.Graph.t(),
          {number(), number()},
          [atom | String.t()],
          Keyword.t()
        ) ::
          Scenic.Graph.t()

  def from_point_layout(graph, point, list_of_prim_ids, opts \\ []) when is_tuple(point) do
    starting_acc = %__MODULE__{
      primitive: nil,
      starting_xy: point,
      grid_xy: point,
      graph: graph,
      padding: opts[:padding] || 0,
      axis: opts[:axis] || :x,
      max_xy: opts[:max_xy] || nil,
      wrap: opts[:wrap] || false
    }

    Enum.reduce(list_of_prim_ids, starting_acc, fn p_id, acc ->
      %Scenic.Primitive{} = primitive = Graph.get!(graph, p_id)

      {:ok, xy, new_layout} =
        acc
        |> Map.put(:primitive, primitive)
        |> do_from_point_layout()

      new_graph =
        new_layout
        |> Map.get(:graph)
        |> Graph.modify(p_id, &update_opts(&1, t: xy))

      Map.put(new_layout, :graph, new_graph)
    end)
    |> Map.get(:graph)
  end

  # get shape data to translate which applies to group
  def from_point_group_layout(graph, point, list_of_prim_ids, opts \\ []) when is_tuple(point) do
    # list of group_ids, get the child primitive to translate the group by, translate, update layout
    starting_acc = %__MODULE__{
      primitive: nil,
      starting_xy: point,
      grid_xy: point,
      graph: graph,
      padding: opts[:padding] || 0,
      axis: opts[:axis] || :x,
      max_xy: opts[:max_xy] || nil,
      wrap: opts[:wrap] || false
    }

    Enum.reduce(list_of_prim_ids, starting_acc, fn p_id, acc ->
      # if child id is passed in, translate based on that rather than picking the first primitive
      {layout, graph} =
        case p_id do
          {p_id, child_prim} ->
            %Scenic.Primitive{} = primitive = Graph.get!(graph, child_prim)

            {:ok, xy, new_layout} =
              acc
              |> Map.put(:primitive, primitive)

              |> do_from_point_layout()

            {new_layout,
            new_layout
            |> Map.get(:graph)
            |> Graph.modify(p_id, &update_opts(&1, t: xy))}

          p_id ->
            %Scenic.Primitive{data: data} = Graph.get!(graph, p_id)

            primitive =
            graph
            |> Map.get(:primitives)
            |> Map.get(hd(data))

            {:ok, xy, new_layout} =
              acc
              |> Map.put(:primitive, primitive)
              |> do_from_point_layout()

            {new_layout,
            new_layout
            |> Map.get(:graph)
            |> Graph.modify(p_id, &update_opts(&1, t: xy))}
        end

      Map.put(layout, :graph, graph)
    end)
    |> Map.get(:graph)
  end

  @doc false
  defp do_from_point_layout(%{primitive: %{module: Scenic.Primitive.Circle}} = layout),
    do: Circle.from_point_translate(layout)

  # Groups containing multiple primtives need to be translated together using the overall size of group bounding box which is essentially a rectangle
  defp do_from_point_layout(%{primitive: %{module: Scenic.Primitive.Group}} = layout),
    do: Group.from_point_translate(layout)

  defp do_from_point_layout(%{primitive: %{module: Scenic.Primitive.Rectangle}} = layout),
    do: Rectangle.from_point_translate(layout)

  defp do_from_point_layout(%{primitive: %{module: Scenic.Primitive.RoundedRectangle}} = layout),
    do: RoundedRectangle.from_point_translate(layout)

  defp do_from_point_layout(%{primitive: %{module: Scenic.Primitive.Arc}} = layout),
    do: Arc.from_point_translate(layout)

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
        new_graph =
          Graph.modify(Map.get(new_layout, :graph), p_id, &update_opts(&1, t: xy))

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

  defp do_layout(module, layout, id),
    do: Logger.debug("#{inspect(module)}, #{inspect(layout)}, #{inspect(id)}")

  # defp do_layout(_, _, _), do: {:error, "Must be a primitive to auto-layout"}
end
