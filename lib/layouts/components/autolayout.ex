defmodule LayoutOMatic.Layouts.Components.AutoLayout do
  @moduledoc """
  Handles Auto-Layouts for Scenic Components.

  Each Scenic component is a little different in how it's sized and positioned. While most components are positioned from it's top left most point, passing the next starting point is
  a little different. Sizing for components are based on font metrics. By determining the dimensions of the font, width and height are calculated and applied to the component. The Layout-O-Matic
  takes care of all of this for you. Width and height can also be passed as style arguments on a component in which case those dimensions will be used.

  Auto-Layout, while a made up term, is used to describe that components will be automatically laid out by positioning components in equal rows and columns. Possibly in the future there may be other
  types of layouts.


  """
  alias Scenic.Graph
  # alias LayoutOMatic.Layouts.Components.RadioGroup
  alias LayoutOMatic.Layouts.Components.Button
  alias LayoutOMatic.Layouts.Components.Checkbox
  alias LayoutOMatic.Layouts.Components.Dropdown
  alias LayoutOMatic.Layouts.Components.Slider
  alias LayoutOMatic.Layouts.Components.TextField
  alias LayoutOMatic.Layouts.Components.Toggle

  import Scenic.Primitives

  defmodule Layout do
    defstruct component: %Scenic.Primitive{},
              starting_xy: {},
              max_xy: {},
              grid_xy: {},
              graph: %{},
              padding: [{:total, 1}],
              margin: [{:total, 1}],
              position: :static,
              float: :none,
              align: :none
  end

  @spec auto_layout(graph :: Graph.t(), group_id :: :atom, list_of_comp_ids :: [:atom]) ::
          Graph.t()
  def auto_layout(graph, group_id, list_of_comp_ids) do
    rect_id =
      group_id
      |> Atom.to_string()
      |> String.split("_")
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
    # case RadioGroup.translate(layout) do
    #   {:ok, {x, y}, new_layout} ->
    #     new_graph = Graph.modify(Map.get(new_layout, :graph), c_id, &update_opts(&1, t: {x, y}))
    #     Map.put(new_layout, :graph, new_graph)

    #   {:error, error} ->
    #     {:error, error}
    # end
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
