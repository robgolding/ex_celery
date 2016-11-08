# ex_celery

[![Build Status](https://travis-ci.org/robgolding/ex_celery.svg?branch=develop)](https://travis-ci.org/robgolding/ex_celery)


A [Celery](http://www.celeryproject.org/) task producer for Elixir. Currently
only supports delaying tasks, not retrieving their result.

## Installation

First, add `ex_celery` to your `mix.exs` dependencies:

```elixir
def deps do
  [{:ex_celery, "~> 0.2.0"}]
end
```

Then, update your dependencies:

```
$ mix deps.get
```

## Usage

Add `ex_celery` to your applications list:

```elixir
def application do
  [applications: [:ex_celery]]
end
```

Add configuration parameters for `ex_celery` using `Mix.Config`:

```elixir
use Mix.Config

config :ex_celery,
       broker_url: "amqp://username:password@host/vhost",
       exchange: "custom_exchange"
```

### Delaying tasks

```elixir
{:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.add", [
    args: [1, 2],
])
{:ok, "f59b0d20-3f2c-46c7-9f01-c787b488e96c"}
{:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.high_priority_task", [
    routing_key: "priority.high",
})
{:ok, "7f9ebbe2-a146-11e6-8328-3c15c2e06802"}
```

### Broker support

RabbitMQ is the only broker currently supported. The `broker_url` is expected
to be in the [AMQP URI format](https://www.rabbitmq.com/uri-spec.html).

_Note: Celery messages will be encoded in JSON format. You must ensure that
`json` is listed in [`CELERY_ACCEPT_CONTENT`](http://docs.celeryproject.org/en/latest/configuration.html#celery-accept-content)._

### Task options

```elixir
{:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.shorten_url", [
    args: ["http://elixir-lang.org/"],
    kwargs: %{allow_duplicates: true},
    routing_key: "tasks.misc",
])
```

## Licence

`ex_celery` is released under the MIT license (see `LICENSE`).
