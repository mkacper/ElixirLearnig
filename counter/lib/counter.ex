defmodule Counter do
  use Application

  def start(_type, _args) do
    Counter.Supervisor.start_link(10)
  end
end
