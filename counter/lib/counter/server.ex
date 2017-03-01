defmodule Counter.Server do
  use GenServer
  @moduledoc """
  Documentation for Counter.
  """

  ##Client API

  @doc """
  Starts counter.
  """
  def start_link(stash_pid) do
    GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def stop do
    GenServer.call(__MODULE__, :stop)
  end

  @doc """
  Gets current value.
  """
  def get do
    request = :get_val
    GenServer.call(__MODULE__, request)
  end

  @doc """
  Increments current value.
  """
  def inc(value) do
    request = {:inc_val, value}
    GenServer.call(__MODULE__, request)
  end

  @doc """
  Decrements current value.
  """
  def dec(value) do
    request = {:dec_val, value}
    GenServer.call(__MODULE__, request)
  end

  @doc """
  Stops server.
  """
  def reset do
    request = :reset_val
    GenServer.cast(__MODULE__, request)
  end

  ## Server Callbacks

  def init(stash_pid) do
    value = Counter.Stash.get_val stash_pid
    {:ok, %{:init_value => value, :current_value => value, stash_pid: stash_pid}}
  end

  def handle_call(:get_val, _from, state = %{current_value: value}) do
    {:reply, value, state}
  end
  def handle_call(
    {:inc_val, value}, _from, state = %{current_value: curr_val}) do
    new_value = calculate_new_val(:inc, curr_val, value)
    {:reply, :ok, %{state | :current_value => new_value}}
  end
  def handle_call(
    {:dec_val, value}, _from, state = %{current_value: curr_val}) do
    new_value = calculate_new_val(:dec, curr_val, value)
    {:reply, :ok, %{state | :current_value => new_value}}
  end
  
  def handle_cast(:reset_val, state = %{init_value: init_value}) do
    {:noreply, Map.put(state, :current_value, init_value)}
  end

  def terminate(_reason, %{stash_pid: pid, current_value: curr_val}) do
    Counter.Stash.save_val pid, curr_val 
  end

  defp calculate_new_val(:inc, curr_value, value) do
    curr_value + value
  end
  defp calculate_new_val(:dec, curr_value, value) do
    curr_value - value
  end
end
