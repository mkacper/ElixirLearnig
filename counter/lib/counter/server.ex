defmodule Counter.Server do
  use GenServer
  @moduledoc """
  Documentation for Counter.
  """

  ##Client API

  @doc """
  Starts counter.
  """
  def start_link(value) do
    GenServer.start_link(__MODULE__, value, name: __MODULE__)
  end

  @doc """
  Gets current value.
  """
  def get do
    request = {:get_val, nil}
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
    request = {:reset_val, nil}
    GenServer.call(__MODULE__, request)
  end

  ## Server Callbacks

  def init(value) do
    {:ok, %{:init_value => value, :current_value => value}}
  end

  def handle_call({:get_val, _}, _from, state) do
    {:reply, Map.get(state, :current_value), state}
  end
  def handle_call({:inc_val, value}, _from, state) do
    new_value = calculate_new_val({:inc, {{:state, state}, {:value, value}}})
    {:reply, :ok, Map.put(state, :current_value, new_value)}
  end
  def handle_call({:dec_val, value}, _from, state) do
    new_value = calculate_new_val({:dec, {{:state, state}, {:value, value}}})
    {:reply, :ok, Map.put(state, :current_value, new_value)}
  end
  def handle_call({:reset_val, _}, _from, state) do
    init_value = Map.get(state, :init_value)
    {:reply, :ok, Map.put(state, :current_value, init_value)}
  end

  defp calculate_new_val({:inc, {{:state, state}, {:value, value}}}) do
    current_val = Map.get(state, :current_value)
    current_val + value
  end
  defp calculate_new_val({:dec, {{:state, state}, {:value, value}}}) do
    current_val = Map.get(state, :current_value)
    current_val - value
  end
end
