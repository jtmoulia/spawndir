defmodule Watcher.PortTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, port} = Watcher.Port.start("/bin/sleep", args: ["1"])
    {:ok, port: port}
  end

  test "get_os_pid function", %{port: port} do
    assert is_integer Watcher.Port.get_os_pid!(port)
  end

  test "basic port worker lifecycle", %{port: port} do
    assert Process.alive?(port)
    TestHelper.kill_watcher_port port
    {:ok, _} = TestHelper.await_death port
    assert !Process.alive?(port)
  end

end