defmodule BuenaVista.MixProject do
  use Mix.Project

  def project do
    [
      app: :buenavista,
      version: "0.1.0",
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  defp description do
    """
    Phoenix Component Library. 
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Francisco Ceruti"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/timetask/buenavista"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 0.18"},
      {:floki, ">= 0.30.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:nimble_options, "~> 1.0"},
      {:typed_struct, "~> 0.3.0", override: true},
      {:gettext, "~> 0.20"}
    ]
  end
end
