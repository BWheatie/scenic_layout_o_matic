defmodule LayoutOMatic.TextPosition do
  @moduledoc """
  While Scenic supports text positioning within a component, it does not support positioning
  based on a point. This works by passing a string and point to be postioned from.
  """
  # Text are translated from the bottom left of the character
  @default_font_size 20
  @default_font :roboto

  # @spec left(any, any) :: none
  # def left(string, {x, y}) do
  #   get_font_metrics(string) |> IO.inspect()
  # end

  # def top() do
  # end

  # def bottom() do
  # end

  # def right() do
  # end

  @doc """
  Centers string according to point.
  """
  @spec center(String.t(), {number, number}) :: {number, number}
  def center(string, {x, y}, font_size \\ @default_font_size, font \\ @default_font) do
    if String.contains?(string, "\n") do
      word_sizes =
        string
        |> String.split("\n")
        |> Enum.map(fn w ->
          get_font_metrics(w, font_size, font)
        end)

      width =
        word_sizes
        |> Enum.map(fn {width, _} ->
          width
        end)
        |> Enum.max()

      height =
        word_sizes
        |> Enum.map(fn {_, height} ->
          height
        end)
        |> Enum.sum()

      {x - trunc(width / 2), y - trunc(height / 2)}
    else
      {width, height} = get_font_metrics(string, font_size, font)

      {x - trunc(width / 2), y + trunc(height / 2)}
    end
  end

  @doc false
  defp get_font_metrics(text, font_size, font) do
    fm = Scenic.Cache.Static.FontMetrics.get!(font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)

    {trunc(fm_width), trunc(ascent)}
  end
end
