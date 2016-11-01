# ex_celery

[![Build Status](https://travis-ci.org/robgolding/ex_celery.svg?branch=master)](https://travis-ci.org/robgolding/ex_celery)


`ex_celery` is a Celery task producer for Elixir. It currently only supports
delaying tasks, not retrieving their result. Here's an example of its use:

```elixir
iex(1)> {:ok, pid} = ExCelery.start_link([broker_url: "amqp://guest:guest@localhost"])

22:27:36.133 [info]  Connected to broker amqp://guest:guest@localhost
{:ok, #PID<0.149.0>}
iex(2)> {:ok, task_id} = ExCelery.apply_async(pid, "my_app.tasks.my_task")
{:ok, "f59b0d20-3f2c-46c7-9f01-c787b488e96c"}
```
