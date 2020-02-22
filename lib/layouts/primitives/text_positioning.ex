defmodule LayoutOMatic.TextPosition do
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

  @spec center(String.t(), {number, number}) :: {number, number}
  def center(string, {x, y}, font_size \\ @default_font_size) do
    if String.contains?(string, "\n") do
      word_sizes =
        string
        |> String.split("\n")
        |> Enum.map(fn w ->
          get_font_metrics(w, font_size)
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
      {width, height} = get_font_metrics(string, font_size)

      {x - trunc(width / 2), y + trunc(height / 2)} |> IO.inspect()
    end
  end

  defp get_font_metrics(text, font_size) do
    fm = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)

    {trunc(fm_width), trunc(ascent)}
  end
end
