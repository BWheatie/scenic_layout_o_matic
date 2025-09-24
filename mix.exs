defmodule LayoutOMatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :scenic_layout_o_matic,
      version: "0.5.0",
      elixir: "~> 1.8",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Scenic Layout-O-Matic",
      source: "https://github.com/BWheatie/layout_o_matic"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # mod: {LayoutOMatic, []},
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:scenic, git: "https://github.com/ScenicFramework/scenic", tag: "v0.12.0-rc.0"},
      # {:scenic_driver_local,
      #  git: "https://github.com/ScenicFramework/scenic_driver_local", tag: "v0.12.0-rc.0"},
      {:font_metrics, "~> 0.5"},
      {:truetype_metrics, "~> 0.6"}
    ]
  end

  defp description() do
    "Brings CSS-like grid as well as auto-layouts for components. This allows
    one to dynamically add components to a scene. The goal is to bring some familiar layout
    apis to Scenic."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/BWheatie/layout_o_matic"}
    ]
  end
end
