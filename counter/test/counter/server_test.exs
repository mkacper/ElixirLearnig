defmodule Counter.ServerTest do
  use ExUnit.Case, async: true

  alias Counter.Server

  test "is counter started with app" do
    {:ok, _} = Application.ensure_all_started(:counter)
    assert Process.alive?(Process.whereis(Counter.Server))
  end

  test "counter increments values" do
    for _ <- 1..1000 do
      # GIVEN
      before = Server.get
      val = Enum.random(1..1000)

      # WHEN
      :ok = Server.inc(val)

      # THEN
      assert Server.get() == before + val
    end
  end

  test "conunter restarts on error" do
    #GIVEN
    pid = Process.whereis(Server)
    ref = Process.monitor(pid)

    # WHEN
    true = Process.exit(pid, :kill)
    assert_receive({:DOWN, ^ref, :process, ^pid, :killed})
    # THEN
    assert is_server_alive() 
    # link to the counter process
    # set :trap_exit flag to true
    # use assert_receive/refute_receive to check it the message is not delivered
  end

  def is_server_alive() do
    case Process.whereis(Server) do
      nil ->
        Process.sleep 100
        Process.whereis(Server) |> is_pid
      pid when is_pid(pid) -> true
    end
  end
end
