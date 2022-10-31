defmodule ExCelery.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_celery,
      version: "0.2.0",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    application(Mix.env())
  end

  def application(:test) do
    [applications: [:logger]]
  end

  def application(_) do
    [
      applications: [:logger],
      mod: {ExCelery.Application, []}
    ]
  end

  defp deps do
    [
      {:amqp_client, git: "https://github.com/jbrisbin/amqp_client.git", override: true},
      {:amqp, "0.1.4"},
      {:poison, "~> 2.2"},
      {:elixir_uuid, "~> 1.2"},
      {:mock, "~> 0.2.0", only: :test}
    ]
  end

  defp description do
    """
    A Celery producer for Elixir. Currently supports the RabbitMQ broker, and
    only publishing tasks (not running them or retrieving their result).
    """
  end

  defp package do
    [
      maintainers: ["Rob Golding"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/robgolding/ex_celery",
        "Docs" => "https://github.com/robgolding/ex_celery"
      }
    ]
  end
end
