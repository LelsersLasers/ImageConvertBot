defmodule ImageConvertBot.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ImageConvertBot
    ]

    opts = [strategy: :one_for_one, name: ImageConvertBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
