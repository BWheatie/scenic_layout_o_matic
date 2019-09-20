defmodule LayoutOMatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :scenic_layout_o_matic,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {LayoutOMatic, []},
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10"},
      {:font_metrics, "~> 0.3"},
      {:nimble_parsec, "~> 0.2"},
      {:floki, "~> 0.23.0"}
    ]
  end
end
