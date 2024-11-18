defmodule ImageConvertBot.Application do
  use Application

  def start(_type, _args) do
    IO.puts("Starting ImageConvertBot")

    children = [ImageConvertBot]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
