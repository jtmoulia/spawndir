defmodule Watcher.Supervisor do
  use Supervisor

  ## Public interface
  def add!(cmd, opts \\ [], watcher_supervisor \\ __MODULE__) do
    case _add(watcher_supervisor, cmd, opts) do
      {:error, error} -> raise "Was unable to properly start the watcher supervisor: #{inspect(error)}"
      {:ok, pid} -> pid
    end
  end
  def add(cmd, opts \\ [], watcher_supervisor \\ __MODULE__) do
     _add(watcher_supervisor, cmd, opts) 
  end
  
  def start_link(opts \\ []) do
    Supervisor.start_link __MODULE__, :ok, opts
  end

  ## Helper functions
  defp _add(watcher_supervisor, cmd, opts) do
    Supervisor.start_child watcher_supervisor, [cmd, opts] 
  end


  ## Supervisor callbacks

  def init(:ok) do
    children = [
      worker(Watcher.Port, [])
    ]
    supervise children, strategy: :simple_one_for_one
  end

end
