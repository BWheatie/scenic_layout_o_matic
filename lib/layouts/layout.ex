defmodule Scenic.Layouts.Layout do
  import Scenic.Primitives

  @viewport :layout_o_matic
          |> Application.get_env(:viewport)
          |> Map.get(:size)

  def grid(number_of_columns, {starting_x, starting_y} \\ @viewport, opts \\ nil) do
    size = round(starting_x / number_of_columns)

    #calculates max x for grid space
    list_of_x =
      Enum.map(number_of_columns..1, fn cols ->
        x = starting_x - size * cols
        case opts[:draw] do
          true ->
            rect_spec({x, starting_y}, stroke: {0.25, :white}, scissor: {x, starting_y})

          _ ->
            rect_spec({x, starting_y}, scissor: {x, starting_y})
        end
      end)
  end

  # def draw_guides(list_of_x, starting_y) do
  #   Enum.map(list_of_x, fn x ->
  #     line_spec({{x, 0}, {x, starting_y}}, stroke: {0.25, :white})
  #   end)
  # end

  # ===========================FIX THIS==========================
  # def columns(num_of_cols), do: :ok

  # # Takes a list of components/primitives, size of the container, options: starting x, y
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
