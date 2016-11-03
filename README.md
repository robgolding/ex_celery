# ex_celery

[![Build Status](https://travis-ci.org/robgolding/ex_celery.svg?branch=develop)](https://travis-ci.org/robgolding/ex_celery)


`ex_celery` is a Celery task producer for Elixir. It currently only supports
delaying tasks, not retrieving their result. Here's an example of its use:

## Installation

First, add `ex_celery` to your `mix.exs` dependencies:

```elixir
def deps do
  [{:ex_celery, "~> 0.1.1"}]
end
```

Then, update your dependencies:

```
$ mix deps.get
```

## Usage

```elixir
iex> {:ok, pid} = ExCelery.start_link([broker_url: "amqp://guest:guest@localhost"])
{:ok, #PID<0.149.0>}
iex> {:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.add", [
...>     args: [1, 2],
...> ])
{:ok, "f59b0d20-3f2c-46c7-9f01-c787b488e96c"}
iex> {:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.high_priority_task", [
...>     routing_key: "priority.high",
...> })
{:ok, "7f9ebbe2-a146-11e6-8328-3c15c2e06802"}
```

### Broker support

RabbitMQ is the only broker currently supported. The `broker_url` is expected
to be in the [AMQP URI format](https://www.rabbitmq.com/uri-spec.html).

You may also specify an `exchange` other than the default (`celery`):

```elixir
iex> {:ok, pid} = ExCelery.start_link([
...>     broker_url: "amqp://username:password@rabbitmq.host/vhost",
...>     exchange: "custom_exchange",
...> ])
{:ok, #PID<0.149.0>}
```

_Note: Celery messages will be encoded in JSON format. You must ensure that
`json` is listed in [`CELERY_ACCEPT_CONTENT`](http://docs.celeryproject.org/en/latest/configuration.html#celery-accept-content)._

### Task options

```elixir
iex> {:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.shorten_url", [
...>     args: ["http://elixir-lang.org/"],
...>     kwargs: %{allow_duplicates: true},
...>     routing_key: "tasks.misc",
...> ])
```


## Licence

`ex_celery` is released under the MIT license (see `LICENSE`).
