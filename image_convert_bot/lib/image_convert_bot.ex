defmodule ImageConvertBot do
  use Nostrum.Consumer

  def handle_event({:MESSAGE_CREATE, msg, _state}) do
    case msg.content do
      "!convert" ->
        Nostrum.Api.create_message(
          msg.channel_id,
          content: "Hello!",
          message_reference: %{message_id: msg.id},
      )
      _ ->
        :ignore
    end
  end

  def handle_event({:READY, _event, _state}) do
    IO.puts "Connected!"
  end

  def handle_event(_), do: :noop
end
