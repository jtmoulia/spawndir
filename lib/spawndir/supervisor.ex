defmodule SpawnDir.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @watcher_supervisor Watcher.Supervisor

  def init(:ok) do
    children = [
      supervisor(@watcher_supervisor, [[name: @watcher_supervisor]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
