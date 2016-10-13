defmodule Factorial do
  @moduledoc """
  Factorial
  """


  def multiply_2([h|t]) do
    h * multiply_2(t)
  end
  def multiply_2([]) do
    1
  end


  def make_list([stop|t], stop) do
    t
  end
  def make_list([h|t], stop) do
    l = [h - 1|[h|t]]
    make_list(l, stop)
  end


  def make_list2([stop|t], stop, pid) do
    send(pid, {:sublist, t})
  end
  def make_list2([h|t], stop, pid) do
    l = [h - 1|[h|t]]
    make_list2(l, stop, pid)
  end


  def split2(0, items, pid) do
    true
  end
  def split2(x, items, pid) do
    stop = x - items
    spawn(Factorial, :make_list2, [[x], stop, pid])
    split2(stop, items, pid)
  end


  def catch_lists(sublists, pid) do
    range = 1..sublists
    l = Enum.map(range, fn x -> receive do {:sublist, list} -> list end end)
    send(pid, {:sublists, l})
  end


  def count_factorial(list, pid) do
    result = multiply_2(list)
    send(pid, {:multiply_result, result})
  end


  @doc """
  Calculate factorial divided number into small parts.
  First param is number you count the factorial of. Second is the number of multiplifications run in one separated process.

  ## Example

  factorial = Factorial.factorial(50, 5)
  """

  def factorial(y, items) when y > 0 and items < y do
    rest = rem(y, items)
    x = y - rest
    rest_list = make_list([y], x);
    sublists = round(x / items)

    catchListPID = spawn(Factorial, :catch_lists, [sublists, self])
    spawn(Factorial, :split2, [x, items, catchListPID])

    result = receive do
      {:sublists, list} -> list
    end
    # result = receive_sublists()

    Enum.map(result, fn x -> spawn(Factorial, :count_factorial, [x, self]) end)
    range = 1..sublists
    final = Enum.map(range, fn x -> receive do {:multiply_result, list} -> list end end)
    final = multiply_2(final)
    final_list = [final|rest_list]
    final_result = multiply_2(final_list)
    final_result

  end
  def factorial(_, _) do
    IO.puts("Params cannot be qual zero and first one must be equal or grater than the second. Try again.")
  end

  # def receive_sublists, do: receive do {:sublists, l} -> l end


  # @proc_count 10

  # def factorial(n) when n <= 50, do: _factorial(n)
  # def factorial(n) when n > 50 do
  #   slice = n div @proc_count
  #   r = rem(n, 10)
  #   _split(_start = 1, _stop = slice, slice)
  #   slices = receive_slices()
  #   multiply_slices(slices) * factorial(@proc_count*slice+1, n)
  # end

  # defp _split(start, stop, slice, pid) do
  #   # spawn fn -> send(pid, {:res, factorial(start, stop)}) end
  #   _split(stop + 1, stop+slice, slice, pid)
  # end

  # defp _factorial(n) when n > 1, do: n * _factorial(n-1)
  # defp _factorial(1), do: 1

end
