defmodule ImageConvertBot.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Starting ImageConvertBot")

    children = [ImageConvertBot]
    IO.inspect(children)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
