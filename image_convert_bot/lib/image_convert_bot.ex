defmodule ImageConvertBot do
  use Nostrum.Consumer

  def handle_event(event) do
    IO.inspect event

    :noop
  end
end
