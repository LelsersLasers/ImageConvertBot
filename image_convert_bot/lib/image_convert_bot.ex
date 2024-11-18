defmodule ImageConvertBot do
  use Nostrum.Consumer

  @folder Path.join([File.cwd!(), "temp"])

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
        Nostrum.Api.create_reaction(msg.channel_id, msg.id, "👍")

        File.mkdir_p!(@folder)

        urls =
          msg.attachments
          |> Enum.map(& &1.url)

        filenames =
          urls
          |> Enum.map(&URI.parse(&1).path)
          |> Enum.map(&(String.split(&1, "/") |> List.last()))

        new_full_filenames =
          Enum.zip(urls, filenames)
          |> Enum.map(fn {url, filename} ->
            response = Req.get!(url)
            full_filename = Path.join([@folder, filename])
            File.write!(full_filename, response.body)

            old_ext =
              filename
              |> Path.extname()

            new_filename =
              filename
              |> Path.basename()
              |> String.replace(old_ext, ".#{type}")

            new_full_filename = Path.join([@folder, new_filename])

            ExMagick.init()
            |> ExMagick.put_image(full_filename)
            |> ExMagick.output(new_full_filename)

            File.rm!(full_filename)

            new_full_filename
          end)

        Nostrum.Api.create_message(
          msg.channel_id,
          content: "Resulting files:",
          message_reference: %{message_id: msg.id},
          files: new_full_filenames
        )

        new_full_filenames
        |> Enum.each(&File.rm!(&1))
      end
    end
  end

  def handle_event({:READY, _event, _state}) do
    IO.puts("Connected!")
  end

  def handle_event(_), do: :noop
end
