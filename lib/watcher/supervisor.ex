defmodule Watcher.Supervisor do
  use Supervisor

  ## Public interface

  def add(cmd, opts \\ [], watcher_supervisor \\ __MODULE__) do
    Supervisor.start_child watcher_supervisor, [cmd, opts]
  end



  def start_link(opts \\ []) do
    Supervisor.start_link __MODULE__, :ok, opts
  end


  ## Supervisor callbacks

  def init(:ok) do
    children = [
      worker(Watcher.Port, [])
    ]
    supervise children, strategy: :simple_one_for_one
  end

end