defmodule SpawnDir do
  @moduledoc """
  The main interface for the `SpawnDir` application.

  """

  use Application

  ## Public interface

  @doc """
  Escript executable entry point.
  """
  def main([]) do
    IO.puts "usage: spawndir DIR [ARGS ...]"
  end

  def main([root | args]) do
    start!
    add root, args: args
    # Don't halt until application is complete
    item = SpawnDir.Supervisor
    monitor = Process.monitor item
    receive do
      {'DOWN', ^monitor, :process, ^item, reason} ->
        IO.puts "Going down due to #{reason}"
        :ok
    end
  end


  @doc """
  Start the `SpawnDir` application, raising an `ApplicationError` if unable to.
  """
  def start! do
    case Application.ensure_all_started :spawndir do
      {:ok, _} ->
        :ok
      {:error, reason} ->
        raise ApplicationError, reason
    end
  end


  @doc """
  Stop the `SpawnDir` application.
  """
  def stop do
    Application.stop :spawndir
  end


  @doc """
  Walks the directory structure opening ports to each available
  command. See `Port.open` for a description of `:opts`.
  """
  def add(root, opts \\ []) do
    walk(root, fn
                 {:file, path} ->
                   # todo - check if file at path is executable
                   Watcher.Supervisor.add path, opts
                 {:dir, _} ->
                   :ok
           end)
  end


  @doc """
  Add the targets supplied in the application config.

  config targets :: path | {path, [opts]}
  """
  def add_from_config(watch_key \\ :watch, default_opts_key \\ :default_opts) do
    default_opts = Application.get_env(:spawndir, default_opts_key, [])
    {:ok,
     for target <- Application.get_env(:spawndir, watch_key, []) do
       case target do
         {path, opts} ->
           add path, opts
         path ->
           add path, default_opts
       end
     end}
  end


  ## Application Callbacks

  def start(_type, _args) do
    result = SpawnDir.Supervisor.start_link
    add_from_config
    result
  end


  ## Private functions

  defp walk(root, func) do
    case File.exists? root do
      true ->
        case File.dir? root  do
          true ->
            func.({:dir, root})
            for path <- File.ls!(root), do: walk(Path.join(root, path), func)
          false ->
            func.({:file, root})
        end
      false ->
        {:error, badfile: root}
    end
  end

end
