defmodule SpawnDirTest do
  use ExUnit.Case, async: false
  use Bitwise

  @dir Application.get_env :spawndir, :test_dir, Path.join("var", "test")
  @default_mode 0777
  @default_content "#!/bin/bash\nsleep 10"
  @tree ["cmd1", "cmd2", {"subdir", ["subcmd1"]}]

  setup do
    File.rm_rf! @dir
    SpawnDir.start!
    :ok = File.mkdir_p(@dir)
    build_tree @tree
    on_exit fn ->
                 SpawnDir.stop
                 File.rm_rf! @dir
            end
    {:ok, dir: @dir, tree: @tree}
  end


  test "spawndir add", %{dir: dir} do
    SpawnDir.add dir
    :timer.sleep 20  # Pause to allow children to spawn
          IO.puts(inspect(Supervisor.count_children(Watcher.Supervisor)));
    assert Supervisor.count_children(Watcher.Supervisor)[:active] == 3
  end


  ## Helper functions

  defp build_tree([{dir, dir_rest} | rest],
                  path, default_content, default_mode, acc) when is_list(dir_rest) do
    dir_path = Path.join path, dir
    File.mkdir_p dir_path
    build_tree(rest, path, default_content, default_mode,
               [build_tree(dir_rest, dir_path) | acc])
  end

  defp build_tree([{cmd, content} | rest],
                  path, default_content, default_mode, acc) when is_binary(content) do
    cmd_path = Path.join path, cmd
    File.write! cmd_path, default_content
    File.chmod! cmd_path, default_mode
    build_tree(rest, path, default_content, default_mode, [path | acc])
  end

  defp build_tree([cmd | rest],
                  path, default_content, default_mode, acc) when is_binary(cmd) do
    build_tree([{cmd, default_content} | rest],
               path, default_content, default_mode, acc)
  end

  defp build_tree([], _, _, _, acc) do
    {:ok, Enum.reverse(acc)}
  end

  defp build_tree(tree,
                  path \\ @dir,
                  default_content \\ @default_content,
                  default_mode \\ @default_mode,
                  acc \\ []) do
    build_tree tree, path, default_content, default_mode, acc
  end

end
