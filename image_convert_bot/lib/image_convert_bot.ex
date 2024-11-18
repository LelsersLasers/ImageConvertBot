defmodule ImageConvertBot do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link() do
    # Starts the Consumer process
    Nostrum.Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "ping!" ->
        Api.create_message(msg.channel_id, "I copy and pasted this code")
      _ ->
        :ignore
    end
  end
end
