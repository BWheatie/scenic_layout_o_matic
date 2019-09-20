defmodule LayoutOMatic.CssParser do
  def parse(file) do
    {:ok, content} = File.read(file)

    content
    |> Floki.parse()
    |> Enum.map(fn con ->
      case con do
        con when is_tuple(con) ->
          con

        con when is_list(con) ->
          child_elements(con)
      end
    end)
  end

  defp child_elements(list) when is_list(list) do
    Enum.reduce(list, fn l ->
      case l do
        l when is_list(l) ->
          child_elements(l)

        l when is_tuple(l) ->
          l
      end
    end)
  end
end
