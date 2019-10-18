defmodule LayoutOMatic do
  use Supervisor
  @viewports :scenic_dyn_viewports

  # --------------------------------------------------------
  @doc false
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor,
      restart: :permanent,
      shutdown: 500
    }
  end

  # --------------------------------------------------------
  @doc false
  def start_link(opts \\ [])
  def start_link({a, b}), do: start_link([{a, b}])

  def start_link(opts) when is_list(opts) do
    Supervisor.start_link(__MODULE__, opts, name: :scenic)
  end

  # --------------------------------------------------------
  @doc false
  def init(opts) do
    opts
    |> Keyword.get(:viewports, [])
    |> do_init
  end

  # --------------------------------------------------------
  # init with no default viewports
  defp do_init([]) do
    [
      {Scenic.ViewPort.Tables, nil},
      supervisor(Scenic.Cache.Support.Supervisor, []),
      {DynamicSupervisor, name: @viewports, strategy: :one_for_one}
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end

  # --------------------------------------------------------
  # init with default viewports
  defp do_init(viewports) do
    [
      {Scenic.ViewPort.Tables, nil},
      supervisor(Scenic.Cache.Support.Supervisor, []),
      supervisor(Scenic.ViewPort.SupervisorTop, [viewports]),
      {DynamicSupervisor, name: @viewports, strategy: :one_for_one}
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
