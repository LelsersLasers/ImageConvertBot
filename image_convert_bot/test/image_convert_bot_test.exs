defmodule ImageConvertBotTest do
  use ExUnit.Case
  doctest ImageConvertBot

  test "greets the world" do
    assert ImageConvertBot.hello() == :world
  end
end
