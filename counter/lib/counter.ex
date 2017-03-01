defmodule Counter do
  @behaviour Application

  def start(_type, _args) do
    Application.get_env(:counter, :init_value)
    |> Counter.Supervisor.start_link
  end

  def stop(app = :counter) do
    Application.stop(app)
    :ok
  end
  def stop(_) do
    {:error, "Invalid name"}
  end
end
