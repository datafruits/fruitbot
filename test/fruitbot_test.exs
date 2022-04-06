defmodule FruitbotTest do
  use ExUnit.Case
  doctest Fruitbot

  test "greets the world" do
    assert Fruitbot.hello() == :world
  end
end
