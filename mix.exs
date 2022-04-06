defmodule Fruitbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :fruitbot,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Fruitbot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_client, "~> 0.3"},
      {:jason, "~> 1.0"},
      {:nostrum, "~> 0.5.1"}
    ]
  end
end
