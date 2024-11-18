defmodule ImageConvertBot.Application do
	use Application

	def start(_type, _args) do
	  children = [ImageConvertBot]
	  Supervisor.start_link(children, strategy: :one_for_one)
	end
end
