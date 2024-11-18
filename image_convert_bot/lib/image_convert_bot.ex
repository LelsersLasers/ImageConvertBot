defmodule ImageConvertBot do
  use Nostrum.Consumer

  def handle_event({:MESSAGE_CREATE, msg, _state}) do
    if String.starts_with?(msg.content, "!convert") do
      type =
        msg.content
        |> String.split(" ", parts: 2)
        |> Enum.at(1)

      if is_nil(type) do
        Nostrum.Api.create_message(
          msg.channel_id,
          content: "Please provide a type to convert to!",
          message_reference: %{message_id: msg.id}
        )
      else
        # content = "Converting to #{type}!" <> " " <> msg.attachments |> Enum.map(& &1.url) |> Enum.join(", ")
        urls =
          msg.attachments
          |> Enum.map(& &1.url)
        Nostrum.Api.create_message(
          msg.channel_id,
          content: "Converting to #{type}!",
          message_reference: %{message_id: msg.id}
        )
      end
    end
  end

  def handle_event({:READY, _event, _state}) do
    IO.puts("Connected!")
  end

  def handle_event(_), do: :noop
end
