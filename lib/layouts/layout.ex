defmodule Scenic.Layouts.Layout do
  alias Scenic.Graph

  import Scenic.Primitives

  def grid(number_of_columns, {max_x, max_y}, opts \\ []) do
    col_size = round(max_x / number_of_columns)

    Enum.map_reduce(1..number_of_columns, opts[:group_ids], fn cols, acc ->
      x = (max_x - col_size) * cols
      id = Atom.to_string(hd(acc))

      {group_spec(
        [rect_spec(
          {x, max_y},
          hidden: Keyword.get(opts, :no_draw, true),
          stroke: {1, :white},
          scissor: {x, max_y},
          id: String.to_atom(id)),
        text_spec(
          ":"<>id,
          hidden: Keyword.get(opts, :no_draw, true),
          fill: :white,
          t: {x - 300, 100})],
        id: String.to_atom(id <> "_" <> "group")), tl(acc)}
    end)
    |> Tuple.to_list()
    |> Enum.map(fn rect ->
      rect
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
