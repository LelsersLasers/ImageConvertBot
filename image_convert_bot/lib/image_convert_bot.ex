defmodule ImageConvertBot do
  use Nostrum.Consumer

  @folder Path.join([File.cwd!(), "temp"])

  def handle_event({:READY, _event, _state}) do
    IO.puts("ImageConvertBot is connected!")
  end

  def handle_event({:MESSAGE_CREATE, msg, _state}) do
    cond do
      msg.author.bot ->
        :noop

      String.starts_with?(msg.content, "!help") ->
        handle_help_command(msg)

      String.starts_with?(msg.content, "!convert") ->
        handle_convert_command(msg)

      true ->
        :noop
    end
  end

  def handle_event(_), do: :noop

  defp handle_help_command(msg) do
    reply_with(
      msg,
      "Use: `!convert <type>` and add images as attachments to convert them.\n" <>
        "Example: `!convert png`"
    )
  end

  defp handle_convert_command(msg) do
    with true <- String.starts_with?(msg.content, "!convert"),
         [_cmd, type] <- String.split(msg.content, " ", parts: 2),
         :ok <- ensure_temp_folder(),
         attachments when attachments != [] <- msg.attachments do
      process_conversion(msg, type, attachments)
    else
      false ->
        :noop

      [_cmd] ->
        reply_with(msg, "Please provide a type to convert to!")

      [] ->
        reply_with(msg, "Please provide at least one image to convert!")
    end
  end

  defp ensure_temp_folder do
    File.mkdir_p!(@folder)
    :ok
  end

  defp process_conversion(msg, type, attachments) do
    msg
    |> fetch_image_urls_and_filenames(attachments)
    |> Enum.map(&download_and_convert_image(&1, type))
    |> send_converted_files(msg)
    |> Enum.each(&File.rm!(&1))
  end

  defp fetch_image_urls_and_filenames(_msg, attachments) do
    Enum.map(attachments, fn %{url: url} ->
      filename = url |> URI.parse() |> Map.get(:path) |> Path.basename()
      {url, filename}
    end)
  end

  defp download_and_convert_image({url, filename}, type) do
    full_filename = Path.join(@folder, filename)
    new_full_filename = Path.join(@folder, Path.rootname(filename) <> ".#{type}")

    url
    |> Req.get!()
    |> Map.get(:body)
    |> (&File.write!(full_filename, &1)).()

    ExMagick.init()
    |> ExMagick.put_image(full_filename)
    |> ExMagick.output(new_full_filename)

    File.rm!(full_filename)
    new_full_filename
  end

  defp send_converted_files(files, msg) do
    Nostrum.Api.create_reaction(msg.channel_id, msg.id, "👍")

    Nostrum.Api.create_message(
      msg.channel_id,
      content: "Resulting files:",
      message_reference: %{message_id: msg.id},
      files: files
    )

    files
  end

  defp reply_with(msg, content) do
    Nostrum.Api.create_message(
      msg.channel_id,
      content: content,
      message_reference: %{message_id: msg.id},
      allowed_mentions: :none
    )
  end
end
