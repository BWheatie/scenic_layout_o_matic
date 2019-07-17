defmodule Scenic.Layouts.Layout do
  alias Scenic.Graph

  import Scenic.Primitives

  defmodule Error do
    @moduledoc false
    defexception message: nil, data: nil
  end

  defmodule Grid do
    @enforce_keys [:max_xy, :grid_ids]
    defstruct [
      :number_of_columns,
      :percent_of_columns,
      :max_xy,
      :starting_xy,
      :grid_ids,
      :column_size,
      :xs_and_ids,
      opts: [:draw]
    ]
  end

  # Takes integer to create equally sized cols
  def grid(%Grid{number_of_columns: num} = grid) when not is_nil(num) do
    {max_x, _} = Map.get(grid, :max_xy)

    Map.put(
      grid,
      :column_size,
      div(max_x, Map.get(grid, :number_of_columns))
    )
    |> build_grid()
  end

  def grid(%Grid{percent_of_columns: percentages} = grid) when not is_nil(percentages) and is_list(percentages) do
    summed_percentages = Enum.sum(percentages)
    case summed_percentages do
      summed_percentages when summed_percentages <= 100 ->
        {max_x, _} = Map.get(grid, :max_xy)

        sizes =
          Enum.map(percentages, fn percent ->
            trunc((percent / 100) * max_x)
          end)

        Map.put(
          grid,
          :column_size,
          sizes
        )
        |> get_x_coordinates()

      _ ->
        raise Error, message: "Percentages must equal 100", data: percentages
    end
  end

  def get_x_coordinates(grid) do
    Map.put(grid, :xs_and_ids,
      Enum.map_reduce(Map.get(grid, :column_size), [], fn col, acc ->
        {starting_x, _} = Map.get(grid, :starting_xy)
        case acc do
          [] ->
            {starting_x + col, starting_x + col}

          _ ->
            {acc + col, acc + col}
        end
      end)
      |> Tuple.to_list()
      |> hd()
      |> Enum.zip(Map.get(grid, :grid_ids)))
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
      id: String.to_atom(Atom.to_string(elem(ix, 1)) <> "_group"))
    end)
  end

  def auto_layout(graph, group, _list_of_specs) do
    [%{data: data}] = Graph.get(graph, group)

    Enum.map(data, fn id ->
      Graph.get(graph, id)
    end)
  end

  # ===========================FIX THIS==========================
  # Takes a list of components/primitives, size of the container, options: starting x, y

  # def build_container(
  #       %{
  #         data: {container_sizex, container_sizey},
  #         styles: %{translate: {container_locationx, container_locationy}}
  #       } = container,
  #       {%{translate: {component_sizex, component_sizey}}, [hd | rest]} = component,
  #       {nil, nil},
  #       []
  #     ) do
  #   component_size

  #   container_edges =
  #     {container_locationx + container_sizex, container_locationy + container_sizey}

  #   case container_edges <= @viewport do
  #     # check if container fits in viewport
  #     true ->
  #       case starting_location do
  #         # First elem to go in container
  #         {nil, nil} ->
  #           {hd, {container_locationx, container_locationy} = starting_location} = translate
  #           translates = [] ++ translate
  #           build_container(container, component, starting_location, translates)

  #         # subsequent elems to go in container
  #         {startingx, startingy} ->
  #           build_container(container, rest, starting_location, translates)
  #       end

  #     false ->
  #       {:error, "Container does not fit in viewport"}
  #   end
  # end

  # def build_container(
  #       %{
  #         data: {container_sizex, container_sizey},
  #         styles: %{translate: {container_locationx, container_locationy}}
  #       } = container,
  #       {%{translate: {component_sizex, component_sizey}}, [hd | rest]} = component,
  #       {startingx, startingy},
  #       translates
  #     ) do
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

  # def still_in_containery?(
  #       {_, startingy},
  #       {_, container_edgey},
  #       {component_width, _}
  #     ) do
  #   startingy + component_width <= container_edgey
  # end

  # def still_in_containerx?(
  #       {startingx, _},
  #       {container_edgex, _},
  #       {_, component_height}
  #     ) do
  #   startingx + component_height <= container_edgex
  # end
end
