defmodule ImageConvertBot do
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _state}) do
    case msg.content do
      "!ping" ->
        Api.create_message(msg.channel_id, "Pong!")
      _ ->
        :ignore
    end
  end

  def handle_event({:READY, _event, _state}) do
    IO.puts "Connected!"
  end

  def handle_event(_), do: :noop
end
