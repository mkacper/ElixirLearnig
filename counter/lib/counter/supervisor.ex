defmodule Counter.Supervisor do
  use Supervisor

  def start_link(value) do
    Supervisor.start_link(__MODULE__, value)
  end

  def init(value) do
    children = [
      worker(Counter.Server, [value])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
