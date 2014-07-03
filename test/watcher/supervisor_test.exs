defmodule Watcher.SupervisorTest do
  use ExUnit.Case, async: false

  ## Top level tests

  setup do
    {:ok, watcher} = Watcher.Supervisor.start_link
    {:ok, watcher: watcher}
  end

  test "add a new port process", %{watcher: watcher} do
    {:ok, watcher_port} = Watcher.Supervisor.add "/bin/sleep", [args: ["1"]], watcher
    assert Process.alive?(watcher_port)
    TestHelper.kill_watcher_port watcher_port
    {:ok, _} = TestHelper.await_death watcher_port
    assert !Process.alive?(watcher_port)
  end

end