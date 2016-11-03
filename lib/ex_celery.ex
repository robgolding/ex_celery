defmodule ExCelery do
  require Logger
  use AMQP
  use GenServer

  def start_link(config \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, config, opts)
  end

  def init(config) do
    broker_url = Keyword.get(config, :broker_url, "amqp://guest:guest@localhost")
    {:ok, channel} = connect(broker_url)
    state = %{
      channel: channel,
      broker_url: broker_url,
      exchange: Keyword.get(config, :exchange, "celery"),
    }
    {:ok, state}
  end

  defp connect(broker_url, attempt \\ 0) do
    case Connection.open(broker_url) do
      {:ok, connection} ->
        Process.monitor(connection.pid)
        Logger.info "Connected to broker #{broker_url}"
        Channel.open(connection)
      {:error, e} ->
        retry_secs = min((attempt + 1) * 2, 32)
        Logger.error "Cannot connect to #{broker_url}: #{inspect e}"
        Logger.error "Trying again in #{retry_secs} seconds..."
        :timer.sleep(retry_secs * 1000)
        connect(broker_url, attempt + 1)
    end
  end

  def apply_async(pid, task, opts \\ []) do
    GenServer.call(pid, {:apply_async, task, opts})
  end

  def handle_call({:apply_async, task, opts}, _from, state) do
    %{channel: channel, exchange: exchange} = state
    args = Keyword.get(opts, :args, [])
    kwargs = Keyword.get(opts, :kwargs, %{})
    {task_id, message} = make_task(task, args, kwargs)
    result = Basic.publish(
      channel,
      exchange,
      Keyword.get(opts, :routing_key, "celery"),
      message,
      [
        content_type: "application/json",
        content_encoding: Keyword.get(opts, :content_encoding, "utf-8"),
        persistent: Keyword.get(opts, :persistent, true),
      ]
    )
    case result do
      :ok -> {:reply, {:ok, task_id}, state}
      e -> {:reply, e, state}
    end
  end

  def handle_cast(request, state) do
    super(request, state)
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    %{broker_url: broker_url} = state
    {:ok, channel} = connect(broker_url)
    {:noreply, {broker_url, channel}}
  end

  defp make_task(task, args, kwargs) do
    task_id = UUID.uuid4()
    message = %{
      id: task_id,
      task: task,
      args: args,
      kwargs: kwargs,
    }
    {task_id, Poison.encode!(message)}
  end

end
