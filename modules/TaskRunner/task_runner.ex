defmodule TaskRunner do
    @moduledoc """
    TaskRunner
    """

    @doc """
    Run task as linked process. Task is fun obj in `f`

    ## Example

        pid = TaskRunner.run_task(fn -> 1+2 end)
    """
    def run_task(f, restarts) do
        pid = spawn(TaskRunner, task_info, [%{:f => f, :restarts => restarts, :restarted => 0}])
        send(:serverPID, {:task_info, pid})
        s = self
        Process.register(s, :run_taskPID)
    end


    def run_task_server(self) do

      p = spawn(TaskRunner, :task_server, [:on])
      Process.register(p, :serverPID)
      s = self
      Process.register(s, :server_runnerPID)
      send(:serverPID, {:msg, :registered})

      receive do
        {:msg, m} -> send(self, m)
      end

    end

    defp task_info(map) do
        receive do
            {:get, key, caller} ->
                send(caller, Map.get(map, key))
                task_info(map) #musi być?
            {:put, key, value} ->
                task_info(Map.put(map, key, value))
        end
    end

    def run_particular_task(f) do
      f.()
    end


    def task_server(state) do
        if state == :on do
            s = self
            Process.flag(:trap_exit, true)
            receive do
              {:msg, :registered} -> send(:server_runnerPID, {:msg, 'Task server started'})
            end
        else
            receive do
                {:task, pid} ->
                    send(pid, {:get, :f, s})
                    receive do
                        f ->
                        p_temp = spawn_link(f)
                        send(:run_taskPID, p_temp)
                    end
                {:EXIT, p, r = {:result, :crashed}} ->
                    pid = p
                    result = r
                    send(pid, {:put, :result, result })
                    send(pid, {:get, :restarted, s})
                    send(pid, {:get, :restarts, s})
                    send(pid, {:get, :f, s})
                    receive do
                        r ->
                            restarted = r
                            receive do
                                r ->
                                    restarts = r
                                    receive do
                                        f ->
                                            if restarted < restarts
                                            f.()
                                            send(pid {:put, :restarted, restarted + 1})
                                    end
                            end
                    end
            end
        end
    end
end