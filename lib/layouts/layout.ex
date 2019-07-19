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
      :column_size,
      :xs_and_ids,
      opts: [:draw]
    ]
  end

  def grid(%Grid{relative_layout: percent} = grid) when not is_nil(percent) do
    {starting_x, _} = Map.get(grid, :starting_xy)
    {max_x, _} = Map.get(grid, :max_xy)

    sizes =
      Enum.map([percent], fn p ->
        trunc(p / 100 * max_x - starting_x)
      end)

    Map.put(
      grid,
      :column_size,
      sizes
    )
    |> get_x_coordinates_percentage()
  end

  def grid(%Grid{equal_layout: num} = grid) when not is_nil(num) do
    {max_x, _} = Map.get(grid, :max_xy)

    Map.put(
      grid,
      :column_size,
      div(max_x, Map.get(grid, :equal_layout))
    )
    |> get_x_coordinates_equal()
  end

  def grid(%Grid{percentage_layout: percentages} = grid)
      when not is_nil(percentages) and is_list(percentages) do
    summed_percentages = Enum.sum(percentages)

    case summed_percentages do
      summed_percentages when summed_percentages <= 100 ->
        {max_x, _} = Map.get(grid, :max_xy)

        sizes =
          Enum.map(percentages, fn percent ->
            trunc(percent / 100 * max_x)
          end)

        Map.put(
          grid,
          :column_size,
          sizes
        )
        |> get_x_coordinates_percentage()

      _ ->
        raise Error, message: "Percentages cannot be more than 100%", data: percentages
    end
  end

  def get_x_coordinates_equal(grid) do
    Map.put(
      grid,
      :xs_and_ids,
      Enum.map_reduce(1..Map.get(grid, :equal_layout), [], fn _, acc ->
        {starting_x, _} = Map.get(grid, :starting_xy)
        size = Map.get(grid, :column_size)

        case acc do
          [] ->
            {starting_x + size, starting_x + size}

          _ ->
            {acc + size, acc + size}
        end
      end)
      |> Tuple.to_list()
      |> hd()
      |> Enum.zip(Map.get(grid, :grid_ids))
    )
    |> build_grid()
  end

  def get_x_coordinates_percentage(grid) do
    Map.put(
      grid,
      :xs_and_ids,
      Enum.map_reduce(Map.get(grid, :column_size), [], fn size, acc ->
        {starting_x, _} = Map.get(grid, :starting_xy)

        case acc do
          [] ->
            {starting_x + size, starting_x + size}

          _ ->
            {acc + size, acc + size}
        end
      end)
      |> Tuple.to_list()
      |> hd()
      |> Enum.zip(Map.get(grid, :grid_ids))
    )
    |> build_grid()
  end

  def build_grid(grid) do
    {_, max_y} = Map.get(grid, :max_xy)

    Enum.map(Map.get(grid, :xs_and_ids), fn ix ->
      group_spec(
        rect_spec({elem(ix, 0), max_y},
          stroke: {1, :white},
          scissor: {elem(ix, 0), max_y},
          id: elem(ix, 1)
        ),
        id: String.to_atom(Atom.to_string(elem(ix, 1)) <> "_group"),
        t: {elem(ix, 0) - Map.get(grid, :column_size), elem(Map.get(grid, :starting_xy), 1)}
      )
    end)
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
