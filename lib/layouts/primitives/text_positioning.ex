defmodule LayoutOMatic.TextPosition do
  @default_font_size 20
  @default_font :roboto

  import Scenic.Primitives

  def left(string, {x, y}) do
    get_font_metrics(string) |> IO.inspect()
  end

  def top() do
  end

  def bottom() do
  end

  def right() do
  end

  def center() do
  end

  defp get_font_metrics(text, font_size \\ @default_font_size) do
    fm = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)

    {fm_width, ascent}
  end
end
