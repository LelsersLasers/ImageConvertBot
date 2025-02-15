defmodule ImageConvertBot do
  use Nostrum.Consumer

  @folder Path.join(File.cwd!(), "temp")
  @input_folder Path.join(@folder, "input")
  @output_folder Path.join(@folder, "output")

  def handle_event({:READY, _event, _state}) do
    IO.puts("ImageConvertBot is connected!")
  end

  def handle_event(
        {:MESSAGE_CREATE, %Nostrum.Struct.Message{author: %{bot: true}} = _msg, _state}
      ),
      do: :noop

  def handle_event({:MESSAGE_CREATE, msg, _state}) do
    case msg.content do
      "!help" <> _ -> handle_help_command(msg)
      "!convert " <> type -> handle_convert_command(msg, type)
      "!convert" -> reply_with(msg, "Please provide a type to convert to!")
      _ -> :noop
    end
  end

  def handle_event(_), do: :noop

  defp handle_help_command(msg) do
    reply_with(
      msg,
      """
      Use: `!convert <type>` and add images as attachments to convert them.
      Example: `!convert png`
      """
    )
  end

  defp handle_convert_command(msg, type) do
    case ensure_temp_folders() do
      :ok ->
        attachments =
          case msg.referenced_message do
            nil -> msg.attachments
            ref_msg -> msg.attachments ++ ref_msg.attachments
          end

        if Enum.empty?(attachments) do
          reply_with(msg, "Please provide at least one image to convert!")
        else
          process_conversion(msg, type, attachments)
        end

      {:error, reason} ->
        reply_with(msg, "Error ensuring temp folders: #{reason}")
    end
  end

  defp ensure_temp_folders do
    try do
      File.mkdir_p!(@folder)
      File.mkdir_p!(@input_folder)
      File.mkdir_p!(@output_folder)
      :ok
    rescue
      e in File.Error -> {:error, e.reason}
    end
  end

  defp process_conversion(msg, type, attachments) do
    Nostrum.Api.create_reaction(msg.channel_id, msg.id, "🫡")
    Nostrum.Api.start_typing(msg.channel_id)

    results =
      attachments
      |> fetch_image_urls_and_filenames()
      |> ensure_unique()
      |> Enum.map(&Task.async(fn -> download_and_convert_image(&1, type) end))
      |> Enum.map(&Task.await(&1, 30_000))

    send_converted_files(results, msg)
    cleanup_files(results)
  end

  defp fetch_image_urls_and_filenames(attachments) do
    Enum.map(attachments, fn %{url: url} ->
      filename = url |> URI.parse() |> Map.get(:path) |> Path.basename()
      {url, filename}
    end)
  end

  defp ensure_unique(url_filenames) do
    Enum.reduce(url_filenames, {[], %{}}, fn {url, filename}, {acc, seen} ->
      rootname = Path.rootname(filename)
      ext = Path.extname(filename)

      {new_filename, new_seen} =
        case Map.get(seen, rootname) do
          nil ->
            {filename, Map.put(seen, rootname, 1)}

          count ->
            unique_name = "#{rootname}_#{count + 1}#{ext}"
            {unique_name, Map.put(seen, rootname, count + 1)}
        end

      {acc ++ [{url, new_filename}], new_seen}
    end)
    |> elem(0)
  end

  defp download_and_convert_image({url, filename}, type) do
    full_filename = Path.join(@input_folder, filename)
    new_full_filename = Path.join(@output_folder, Path.rootname(filename) <> ".#{type}")

    # try do
    url
    |> Req.get!()
    |> Map.get(:body)
    |> (&File.write!(full_filename, &1)).()

    ExMagick.init()
    |> ExMagick.put_image(full_filename)
    |> ExMagick.output(new_full_filename)

    File.rm!(full_filename)

    if File.exists?(new_full_filename) do
      {:ok, new_full_filename}
    else
      rootname = Path.rootname(filename)
      wildcard_pattern = Path.join(@output_folder, "#{rootname}-*#{type}")

      IO.inspect(wildcard_pattern)

      case Path.wildcard(wildcard_pattern) do
        [] ->
          {:error, filename}

        matches ->
          # last_match = List.last(matches)
          IO.inspect(matches)

          last_match =
            matches
            |> Enum.max_by(
              &(Path.basename(&1)
                |> String.split("-")
                |> List.last()
                |> String.to_integer())
            )

          IO.inspect(last_match)

          File.rename!(last_match, new_full_filename)

          IO.puts("Removing all other matches")

          matches
          |> Enum.drop(-1)
          |> Enum.each(&File.rm/1)

          IO.puts("Done removing all other matches")

          {:ok, new_full_filename}
      end
    end

    # rescue
    #   _ ->
    #     File.rm(new_full_filename)
    #     {:error, filename}
    # end
  end

  defp send_converted_files(results, msg) do
    failed_message =
      results
      |> Enum.filter(fn
        {:error, _} -> true
        _ -> false
      end)
      |> Enum.map_join(fn {:error, filename} -> "\n- Error: *#{Path.basename(filename)}*" end)

    files =
      results
      |> Enum.filter(fn
        {:ok, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, filename} -> filename end)

    Nostrum.Api.create_message(
      msg.channel_id,
      content: "Resulting files:" <> failed_message,
      message_reference: %{message_id: msg.id},
      files: files
    )
  end

  defp cleanup_files(results) do
    Enum.each(results, fn
      {:ok, filename} -> File.rm!(filename)
      _ -> :noop
    end)
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
