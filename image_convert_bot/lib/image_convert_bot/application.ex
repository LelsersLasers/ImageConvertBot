defmodule ImageConvertBot.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Starting ImageConvertBot")

    # children = [ImageConvertBot]
    # IO.inspect(children)
    # Supervisor.start_link(children, strategy: :one_for_one)
    {:ok, pid} = ImageConvertBot.start_link(__MODULE__)
    IO.puts(pid)
  end
end
