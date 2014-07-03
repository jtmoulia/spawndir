defmodule Watcher.Port do
  use GenServer

  @default_options [:binary, :exit_status, {:line, 800}]

  ## Client API

  @doc """
  Starts the port command watcher standalone.
  """
  def start(cmd, port_opts) do
    GenServer.start __MODULE__, {cmd, port_opts}
  end


  @doc """
  Starts the port command watcher as part of the supervision tree.
  """
  def start_link(cmd, port_opts \\ []) do
    GenServer.start_link __MODULE__, {cmd, port_opts}
  end


  @doc """
  Returns the os pid of the watched process.
  """
  def get_os_pid!(watcher_port) do
    {:os_pid, os_pid} = Port.info get_port(watcher_port), :os_pid
    os_pid
  end


  ## Server Callbacks

  def init({cmd, opts}) do
    port = Port.open {:spawn_executable, cmd}, @default_options ++ opts
    {:ok, %{port: port}}
  end

  def handle_call({:get, :port}, _, %{port: port} = state) do
    {:reply, port, state}
  end


  def handle_info({port, {:exit_status, 0}}, %{port: port} = state) do
    {:stop, :normal, state}
  end

  def handle_info({port, {:exit_status, exit_status}}, %{port: port} = state) do
    {:stop, {:exit_status, exit_status}, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate({:exit_status, _}, _) do
    :ok
  end

  # todo: send eof to the port process
  def terminate(_reason, %{port: port}) do
    try do
      Port.close port
    rescue ArgumentError ->
        :ok  # The port might already be closed
    end
  end

  ## Private functions

  defp get_port(watcher_port) do
    GenServer.call watcher_port, {:get, :port}
  end
end
