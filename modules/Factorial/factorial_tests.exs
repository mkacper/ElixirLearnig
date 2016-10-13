ExUnit.start()

defmodule FactorialTests do
  use ExUnit.Case

  test "Factorial basic test" do
    assert Factorial.factorial(20,5) == 2432902008176640000
  end

  test "Error messages is printed on bad arguments" do
    alias ExUnit.CaptureIO
    assert CaptureIO.capture_io(fn -> Factorial.factorial(20,21) end)
    == "Params cannot be qual zero and first one must be equal or grater than the second. Try again.\n"
  end
  
end
