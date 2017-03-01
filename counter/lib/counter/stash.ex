defmodule Counter.Stash do
  use GenServer

  ####
  # External API

  def start_link(val) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, val)
  end

  def save_val(pid, val) do
    GenServer.cast pid, {:save_val, val}
  end

  def get_val(pid) do
    GenServer.call pid, :get_val
  end

  ####
  # GenServer implementation

  def handle_call(:get_val, _from, val) do
    {:reply, val, val}
  end

  def handle_cast({:save_val, save_val}, _val) do
    {:noreply, save_val}
  end
end
