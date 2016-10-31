defmodule ExCeleryTest do
  use ExUnit.Case

  @broker_url "amqp://guest:guest@localhost"

  setup do
    {:ok, amqp} = AMQP.Connection.open(@broker_url)
    {:ok, chan} = AMQP.Channel.open(amqp)

    AMQP.Queue.declare(chan, "celery")
    AMQP.Exchange.declare(chan, "celery", :topic)
    AMQP.Queue.bind(chan, "celery", "celery", [
      routing_key: "#",
    ])

    {:ok, celery} = ExCelery.start_link(@broker_url)
    {:ok, %{chan: chan, celery: celery}}
  end

  defp get_message(chan) do
    {:ok, payload, meta} = AMQP.Basic.get(chan, "celery", [no_ack: true])
    {Poison.Parser.parse!(payload), meta}
  end

  test "apply_async empty", %{chan: chan, celery: celery} do
    ExCelery.apply_async(celery, "test.task", [], %{})
    :timer.sleep(100)
    {payload, meta} = get_message(chan)
    assert payload["task"] == "test.task"
    assert payload["args"] == []
    assert payload["kwargs"] == %{}
    assert meta[:content_encoding] == "utf-8"
    assert meta[:content_type] == "application/json"
  end

  test "apply_async with args", %{chan: chan, celery: celery} do
    ExCelery.apply_async(celery, "test.task", ["arg_1"], %{"kwarg_1": "value_1"})
    :timer.sleep(100)
    {payload, meta} = get_message(chan)
    assert payload["task"] == "test.task"
    assert payload["args"] == ["arg_1"]
    assert payload["kwargs"] == %{"kwarg_1" => "value_1"}
    assert meta[:content_type] == "application/json"
    assert meta[:content_encoding] == "utf-8"
    assert meta[:persistent] == true
  end

  test "apply_async with opts", %{chan: chan, celery: celery} do
    ExCelery.apply_async(celery, "test.task", [], %{}, [
      routing_key: "test",
      content_encoding: "ascii",
      persistent: false
    ])
    :timer.sleep(100)
    {payload, meta} = get_message(chan)
    assert meta[:routing_key] == "test"
    assert meta[:content_encoding] == "ascii"
    assert meta[:persistent] == false
  end
end
