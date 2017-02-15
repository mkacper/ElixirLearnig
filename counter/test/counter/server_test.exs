defmodule Counter.ServerTest do
  use ExUnit.Case, async: true


  test "manage counter" do
    assert Counter.Server.get == 10

    assert Counter.Server.inc(20) == :ok

    assert Counter.Server.get == 30

    assert Counter.Server.dec(30) == :ok

    assert Counter.Server.get == 0

    assert Counter.Server.reset == :ok

    assert Counter.Server.get == 10
  end
end
