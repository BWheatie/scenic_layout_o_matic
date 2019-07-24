defmodule Scenic.Layouts.Layout do
  alias Scenic.Graph

  import Scenic.Primitives

  defmodule Error do
    @moduledoc false
    defexception message: nil, data: nil
  end

  # Relative units? grid relative to another grid thereby relative to the group.
  defmodule Grid do
    @enforce_keys [:max_xy, :grid_ids]
    defstruct [
      :relative_layout,
      :equal_layout,
      :percentage_layout,
      :max_xy,
      :starting_xy,
      :grid_ids,
      :column_sizes,
      opts: [:draw]
    ]
  end

  def grid(%Grid{relative_layout: percent} = grid) when not is_nil(percent) do
    {starting_x, _} = Map.get(grid, :starting_xy)
    {max_x, _} = Map.get(grid, :max_xy)

    Map.put(
      grid,
      :column_sizes,
      Enum.map([percent], fn p ->
        trunc(p / 100 * max_x - starting_x)
      end)
    )
    |> get_x_coordinates()
  end

  def grid(%Grid{equal_layout: num} = grid) when not is_nil(num) do
    {max_x, _} = Map.get(grid, :max_xy)

    Map.put(
      grid,
      :column_sizes,
      Enum.map(1..Map.get(grid, :equal_layout), fn _ ->
        div(max_x, Map.get(grid, :equal_layout))
      end)
    )
    |> get_x_coordinates()
  end

  def grid(%Grid{percentage_layout: percentages} = grid)
      when not is_nil(percentages) and is_list(percentages) do
    case Enum.sum(percentages) do
      sum when sum <= 100 ->
        {max_x, _} = Map.get(grid, :max_xy)

        Map.put(
          grid,
          :column_sizes,
          Enum.map(percentages, fn percent ->
            trunc(percent / 100 * max_x)
          end)
        )
        |> get_x_coordinates()

      _ ->
        raise Error, message: "Percentages cannot be more than 100%", data: percentages
    end
  end

  def get_x_coordinates(grid) do
    ids_and_sizes = Enum.zip(Map.get(grid, :grid_ids), Map.get(grid, :column_sizes))

    Enum.map_reduce(ids_and_sizes, [], fn i, acc ->
      starting_xy = Map.get(grid, :starting_xy)
      {_, max_y} = Map.get(grid, :max_xy)

      case acc do
        [] ->
          {build_grid(max_y, elem(i, 1), starting_xy, elem(i, 0)),
           elem(starting_xy, 0) + elem(i, 1)}

        _ ->
          {build_grid(max_y, elem(i, 1), {acc, elem(starting_xy, 1)}, elem(i, 0)),
           acc + elem(i, 1)}
      end
    end)
    |> elem(0)
  end

  def build_grid(max_y, size, starting_xy, id) do
    group_spec(
      rect_spec({size, max_y},
        stroke: {1, :white},
        scissor: {size, max_y},
        id: id
      ),
      id: String.to_atom(Atom.to_string(id) <> "_group"),
      t: {elem(starting_xy, 0), elem(starting_xy, 1)}
    )
  end

  # def auto_layout(group_id, list_of_specs) do

  #   Enum.map(list_of_specs, fn spec ->
  #     [%{}] = Graph.get(grid, spec)
  #     case  do
  #       translate when is_integer(translate) ->
  #         # This is a circle
  #       translate when is_binary(translate) ->
  #         # This is text
  #       translate when is_tuple(translate) ->
  #         # This is everything else
  #     end
  #   end)
  #   case still_in_containery?(starting_location, container_edges, {nil, component_width}) do
  #     # elem fits in y of container
  #     true ->
  #       case still_in_containerx?(
  #              starting_location,
  #              container_edges,
  #              {component_height, nil}
  #            ) do
  #         # elem fits in x of container; elem fits in container
  #         true ->
  #           {hd, {startingx, startingy + component_width} = starting_location} = translate
  #           build_container(container, rest, starting_location, translates ++ translate)

  #         # shouldnt get here?
  #         false ->
  #           {:error, "Something went wrong"}
  #       end

  #     # does not fit in y of container; check if it still fits in x of container
  #     false ->
  #       case still_in_containerx?(
  #              {startingx + component_height, nil},
  #              container_edges,
  #              {component_height, nil}
  #            ) do
  #         # fits in x of container; check if it will fit new y in container
  #         true ->
  #           case still_in_containery?(
  #                  {nil, startingy + component_width},
  #                  container_edges,
  #                  {nil, component_width}
  #                ) do
  #             # fits new row of container
  #             true ->
  #               {hd, {startingx + component_height, startingy} = starting_location} = translate
  #               build_container(container, rest, starting_location, translates ++ translate)

  #             # shouldnt get here?
  #             _ ->
  #               {:error, "Something went wrong"}
  #           end

  #         # container is full
  #         false ->
  #           {:error, "Container full"}
  #       end
  #   end
  # end

  # def still_in_containerx?(
  #       {startingx, _},
  #       {container_edgex, _},
  #       {_, component_height}
  #     ) do
  #   startingx + component_height <= container_edgex
  # end
  # # ===========================FIX THIS==========================
  # # def still_in_containery?(
  # #       {_, startingy},
  # #       {_, container_edgey},
  # #       {component_width, _}
  # #     ) do
  # #   startingy + component_width <= container_edgey
  # # end
end
