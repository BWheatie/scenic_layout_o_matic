defmodule LayoutOMatic.TextPosition do
  @moduledoc """
  While Scenic supports text positioning within a component, it does not support positioning
  based on a point. This works by passing a string and point to be postioned from.
  """

  # Text are translated from the bottom left of the character

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

  # @spec fit_to_size(String.t(), {number, number}, {number, number}) :: bitstring
  # def fit_to_size(string, {starting_x, _}, {max_x, _}, font_size) do
  #   space_width = max_x - starting_x
  #   fm = Scenic.Cache.Static.FontMetrics.get(:roboto)

  #   # FontMetrics.wrap(string, space_width, font_size, fm)
  #   [string] =
  #     fit_in_space(String.split(string), [""], space_width, fm, font_size) |> List.flatten()

  #   string
  # end

  # defp fit_in_space([hd | tl], [[string_hd] | _string_tl] = string, space_size, fm, font_size) do
  #   string_width = FontMetrics.width(string_hd, font_size, fm)
  #   word_width = FontMetrics.width(hd <> " ", font_size, fm)

  #   if Enum.empty?(string_hd) do
  #     cond do
  #       word_width < space_size ->
  #         fit_in_space(tl, [hd <> " "], space_size, fm, font_size)

  #       word_width == space_size and Enum.empty?(tl) ->
  #         [hd]

  #       word_width == space_size ->
  #         fit_in_space(tl, [hd <> "\n"], space_size, fm, font_size)

  #       word_width > space_size ->
  #         {:error, "text too big to fit in area"}
  #     end
  #   else
  #     cond do
  #       word_width + string_width < space_size and Enum.empty?(tl) ->
  #         fit_in_space(tl, concat_new_old_string(hd, string_hd), space_size, fm, font_size)

  #       word_width + string_width < space_size ->
  #         fit_in_space(tl, concat_new_old_string(hd, string_hd), space_size, fm, font_size)

  #       word_width + string_width == space_size and Enum.empty?(tl) ->
  #         concat_new_old_string(hd, string_hd)

  #       word_width + string_width == space_size ->
  #         line_list = concat_new_old_string(hd, string_hd) ++ string_list |> Enum.reverse()
  #         fit_in_space(tl, , space_size, fm, font_size)

  #       word_width + string_width > space_size ->
  #         if String.starts_with?(reverse_word(string_hd), "\n") do
  #           cond do

  #           end
  #         end
  #     end
  #   end
  # end

  # defp do_fit_in_space(new_string, old_string, space_size, old_string_width, ) do

  # end

  # defp concat_new_old_string(new_string, old_string) do
  #   reversed_word = reverse_word(old_string)
  #   reversed_new_word = " " <> new_string
  #   appended_reverse = reversed_new_word ++ reversed_word
  #   appended_reverse |> Enum.reverse() |> to_string()
  # end

  # defp reverse_word(string) do
  #   string
  #   |> Sting.to_charlist()
  #   |> Enum.reverse()
  # end

  # defp fit_in_space([hd | tl] = split_string, string, space_size) do
  #   # IO.inspect({split_string, string})
  #   # string is split so take each head and see if it
  #   # will fit on the current line.
  #   # If the current line string plus the new word < the space -> just concat that
  #   # If the current line string plus the new word == the space -> concat and add a line break
  #   # If the current line string plus the new word > the space -> just add a line break
  #   cond do
  #     String.length(string <> " " <> hd) < space_size ->
  #       fit_in_space(tl, string <> " " <> hd, space_size)

  #     String.length(string <> " " <> hd) == space_size ->
  #       fit_in_space(tl, string <> " " <> hd <> "\n", space_size)

  #     String.length(string <> " " <> hd) > space_size ->
  #       fit_in_space(split_string, string <> "\n", space_size)
  #   end
  # end

  # defp fit_in_space([], string, _) do
  #   string
  # end

  @doc """
  Centers string according to point.
  """
  @spec center(String.t(), {number, number}, number, atom() | binary()) :: {number, number}
  def center(string, {x, y}, font_size, font \\ :roboto) do
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

      {x - width / 2, y - height / 4}
    else
      {width, height} = get_font_metrics(string, font_size, font)

      {x - width / 2, y + height / 4}
    end
  end

  defp get_font_metrics(text, font_size, font) do
    fm = Scenic.Cache.Static.FontMetrics.get(font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)

    {fm_width, ascent}
  end
end
