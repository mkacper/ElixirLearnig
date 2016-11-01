defmodule Factorial do
  @moduledoc """
  Factorial
  """

  @doc """
  Count factorial of a number using some number of separated processes. Number is integer in `n`.

  ## Example

      result = Factorial.factorial(60)
  """

  @proc_count 10

  def factorial(n) when n <= 50, do: _factorial(1, n)
  def factorial(n) when n > 50 do
    slice = div(n, @proc_count)
    r = rem(n, @proc_count)
    _split(_start = 1, _stop = slice, slice, _pid = self)
    slices = _receive_slices([])
    case r do
      0 -> _multiply(slices)
      1 -> _multiply(slices) * n
      _ -> _multiply(slices) * _factorial(@proc_count*slice+1, n)
    end
  end

  defp _split(start, stop, slice, pid) when start < slice*@proc_count do
    spawn fn -> send(pid, {:res, _factorial(start, stop)}) end
    _split(stop, stop+slice, slice, pid)
  end
  defp _split(start, stop, slice, pid) do
    :ok
  end

  defp _factorial(start, start) when start >= 1, do: 1
  defp _factorial(start, stop) when start >= 1, do: stop * _factorial(start, stop-1)
  defp _factorial(1, 1), do: 1

  defp _receive_slices(slices) when length(slices) < @proc_count do
    receive do
      {:res, result} ->
        slices = [result|slices]
        _receive_slices(slices)
    end
  end
  defp _receive_slices(slices) do
    slices
  end

  defp _multiply([h|t]) do
    h * _multiply(t)
  end
  defp _multiply([]) do
    1
  end

end