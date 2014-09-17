defmodule TestHelper do
  def await_death(item, timeout \\ 5000) do
    case Process.alive? item do
      true ->
        monitor = Process.monitor item
        receive do
          {:DOWN, ^monitor, :process, ^item, reason} ->
            {:ok, reason}
        after
          timeout ->
            {:error, :timeout}
        end
      false ->
        {:ok, :already_dead}
    end
  end

  def kill_watcher_port(port) do
    os_pid = Watcher.Port.get_os_pid! port
    System.cmd "kill", ["#{os_pid}"]
  end
end

ExUnit.start
