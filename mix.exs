defmodule Venom.MixProject do
  use Mix.Project

  def project do
    [
      app: :venom,
      version: "0.1.0",
      elixir: "~> 1.16",
      description: "An NBT decoder and encoder written in pure Elixir.",
      package: package(),
      deps: deps(),
      docs: [extras: ["README.md"]],
    ]
  end

  def package do
    [ name: :venom,
      files: ["lib", "mix.exs"],
      maintainers: ["Ben Griffiths"],
      licenses: ["AGPLv3"],
      links: %{"Github" => "https://github.com/Bentechy66/Venom"},
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end
end
