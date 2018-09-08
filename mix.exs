defmodule Ktsllex.MixProject do
  use Mix.Project

  def project do
    [
      app: :ktsllex,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1.0"},
      {:confex, "~> 3.3.1"},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 1.0"}
    ]
  end

  defp description, do: "Kafka Topic and Schema creator"

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Ian Vaughan"],
      licenses: ["MIT"],
      links: %{repository: "https://github.com/quiqupltd/ktsllex"}
    ]
  end

  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test"],
      consistency: consistency()
    ]
  end

  defp consistency do
    [
      "credo --strict"
    ]
  end
end
