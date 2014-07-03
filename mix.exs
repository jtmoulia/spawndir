defmodule SpawnDir.Mixfile do
  use Mix.Project

  @state_dir "var"
  @test_dir Path.join(@state_dir, "test")

  def project do
    [app: :spawndir,
     description: File.read!("README.md"),
     contributors: ["Thomas Moulia <jtmoulia@pocketknife.io>"],
     licenses: ["The BSD 3-Clause License"],
     links: %{github: "https://github.com/jtmoulia/spawndir"},
     version: "0.1.0",
     elixir: "~> 0.14.2",
     deps: deps,
     escript: escript
    ]
  end

  def application do
    [applications: [],
     mod: {SpawnDir, []},
     env: [test_dir: @test_dir]]
  end

  defp deps do
    [#{:exactor, git: "https://github.com/sasa1977/exactor.git", tag: "0.5.0"},
     {:exrm, "~> 0.10.3"}]
  end

  defp escript do
    [main_module: SpawnDir]
  end

end
