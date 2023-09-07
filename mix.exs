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
      extra_applications: [:logger, :ssl, :inets],
      mod: {Fruitbot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:cowlib, "~> 2.11", hex: :remedy_cowlib, override: true},
      {:slipstream, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:nostrum, "~> 0.5.1"},
      {:httpoison, "~> 2.0"},
      {:tmi, git: "https://github.com/mcfiredrill/tmi.ex" },
      {:castore, "~> 1.0"},
    ]
  end
end
