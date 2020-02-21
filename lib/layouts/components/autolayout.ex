defmodule LayoutOMatic.ComponentLayout do
  @moduledoc """
  Handles Auto-Layouts for Scenic Components.

  Each Scenic component is a little different in how it's sized and positioned. While most components are positioned from it's top left most point, passing the next starting point is
  a little different. Sizing for components are based on font metrics. By determining the dimensions of the font, width and height are calculated and applied to the component. The Layout-O-Matic
  takes care of all of this for you. Width and height can also be passed as style arguments on a component in which case those dimensions will be used.

  Auto-Layout, while a made up term, is used to describe that components will be automatically laid out by positioning components in equal rows and columns. Possibly in the future there may be other
  types of layouts.

  Layout takes data like the component, starting {x,y}, grid {x,y}, graph which are required to do any autolayouting. Optionally layout can apply padding to a group which will pad the groups elements
  within the groups grid. Options here include: `:padding-top`, `:padding-right`, `:padding-bottom`, `:padding-left`. These are followed by an integer representing the number of pixels to pad by.
  Percentages are not currently supported. This also supports padding shorthand: {10, 10, 5} which will apply 10 px padding to the top and right and left then 5 px to the bottom. With this pattern
  a single value will apply to all sides.

  To achieve something which mimics a fixed position, use a separate grid or scene which occupies that space of the viewport and use the max {x, y} of that grid/scene and the min {x, y} for every
  subsequent scene.

  Objects can be positioned relative to other elements by using passing `:absolute, <group_id_to_position_relative_to`>, {top_pixels, right_pixels, bottom_pixels, left_pixels}`
  """
  alias Scenic.Graph
  alias LayoutOMatic.Button
  alias LayoutOMatic.Checkbox
  alias LayoutOMatic.Dropdown
  alias LayoutOMatic.Slider
  alias LayoutOMatic.TextField
  alias LayoutOMatic.Toggle

  import Scenic.Primitives

  defmodule Layout do
    defstruct component: %Scenic.Primitive{},
              starting_xy: {},
              max_xy: {},
              grid_xy: {},
              graph: %{}
  end

  @spec auto_layout(Scenic.Graph.t(), atom, [atom]) :: {:ok, Scenic.Graph.t()}
  def auto_layout(graph, group_id, list_of_comp_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_group")
      |> hd()
      |> String.to_atom()

    [%{transforms: %{translate: grid_xy}}] = Graph.get(graph, group_id)
    [%{data: max_xy}] = Graph.get(graph, rect_id)

    graph =
      Enum.reduce(list_of_comp_ids, [], fn c_id, acc ->
        [%{data: {comp_type, _}} = component] = Graph.get(graph, c_id)

        layout =
          case acc do
            [] ->
              %Layout{
                component: component,
                starting_xy: grid_xy,
                max_xy: max_xy,
                grid_xy: grid_xy,
                graph: graph
              }

            _ ->
              acc
          end

        do_layout(comp_type, layout, c_id)
      end)
      |> Map.get(:graph)

    {:ok, graph}
  end

  defp do_layout(Scenic.Component.Button, layout, c_id) do
    case Button.translate(layout) do
      {:ok, {x, y}, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Component.Input.Checkbox, layout, c_id) do
    case Checkbox.translate(layout) do
      {:ok, {x, y}, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Component.Input.Dropdown, layout, c_id) do
    case Dropdown.translate(layout) do
      {:ok, {x, y}, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Component.Input.RadioGroup, _layout, _c_id) do
    nil
  end

  defp do_layout(Scenic.Component.Input.Slider, layout, c_id) do
    case Slider.translate(layout) do
      {:ok, {x, y}, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Component.Input.TextField, layout, c_id) do
    case TextField.translate(layout) do
      {:ok, {x, y}, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end

  defp do_layout(Scenic.Component.Input.Toggle, layout, c_id) do
    case Toggle.translate(layout) do
      {:ok, {x, y}, new_layout} ->
        new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
        Map.put(new_layout, :graph, new_graph)

      {:error, error} ->
        {:error, error}
    end
  end
end
