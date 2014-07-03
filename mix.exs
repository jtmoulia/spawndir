defmodule SpawnDir.Mixfile do
  use Mix.Project

  @state_dir "var"
  @test_dir Path.join(@state_dir, "test")

  def project do
    [app: :spawndir,
     version: "0.0.1",
     elixir: "~> 0.14.2",
     escript: escript
    ]
  end

  def application do
    [applications: [],
     mod: {SpawnDir, []},
     env: [test_dir: @test_dir]]
  end

  def escript do
    [main_module: SpawnDir]
  end

end
