defmodule ExCelery.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_celery,
      version: "0.1.1",
      description: description(),
      package: package(),
      deps: deps(),
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:amqp_client, git: "https://github.com/jbrisbin/amqp_client.git", override: true},
      {:amqp, "0.1.4"},
      {:poison, "~> 2.2"},
      {:uuid, "~> 1.1"},
      {:mock, "~> 0.2.0", only: :test},
    ]
  end

  defp description do
    """
    Celery producer for Elixir;
    """
  end

  defp package do
    [
     maintainers: ["Rob Golding"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/robgolding/ex_celery",
       "Docs" => "http://robgolding.github.io/ex_celery/",
     },
  ]
  end
end
