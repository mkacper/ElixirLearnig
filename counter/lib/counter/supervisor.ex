defmodule Counter.Supervisor do
  use Supervisor

  def start_link(value) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, value)
    start_workers(sup, value)
    result
  end

  def start_workers(sup, value) do
    {:ok, stash} = Supervisor.start_child(sup, worker(Counter.Stash, [value]))
    Supervisor.start_child(sup, supervisor(Counter.SubSupervisor, [stash]))
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end
end
