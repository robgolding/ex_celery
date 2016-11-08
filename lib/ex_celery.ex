defmodule ExCelery do
  require Logger
  use AMQP
  use GenServer

  @default_broker_url "amqp://guest:guest@localhost"
  @default_exchange "celery"

  def start_link(options \\ []) do
    broker_url = Keyword.get(options, :broker_url, default_config(:broker_url, @default_broker_url))
    {:ok, channel} = connect(broker_url)
    state = %{
      channel: channel,
      broker_url: broker_url,
      exchange: Keyword.get(options, :exchange, default_config(:exchange, @default_exchange)),
    }
    GenServer.start_link(__MODULE__, state, Keyword.merge([name: __MODULE__], options))
  end

  def apply_async(task, options \\ []) do
    name = Keyword.get(options, :name, __MODULE__)
    GenServer.call(name, {:apply_async, task, options})
  end

  def handle_call({:apply_async, task, options}, _from, state) do
    %{channel: channel, exchange: exchange} = state
    args = Keyword.get(options, :args, [])
    kwargs = Keyword.get(options, :kwargs, %{})
    {task_id, message} = make_task(task, args, kwargs)
    result = Basic.publish(
      channel,
      exchange,
      Keyword.get(options, :routing_key, "celery"),
      message,
      [
        content_type: "application/json",
        content_encoding: Keyword.get(options, :content_encoding, "utf-8"),
        persistent: Keyword.get(options, :persistent, true),
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

  defp default_config(key, fallback) do
    Application.get_env(:ex_celery, key, fallback)
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
