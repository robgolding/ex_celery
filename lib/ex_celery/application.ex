defmodule ExCelery.Application do
  use Application

  def start(_type, _args) do
    ExCelery.Supervisor.start_link([])
  end
end
