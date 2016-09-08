defmodule XeeThemeScript.Mixfile do
  use Mix.Project

  def project do
    [app: :xeethemescript,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    A Behaviour Module to define a Xee theme.
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :xeethemescript,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Ryo Hashiguchi"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/xeejp/xee-theme-script"}]
  end

  defp deps do
    [{:ex_doc, "~> 0.13.0", only: :dev}]
  end
end
