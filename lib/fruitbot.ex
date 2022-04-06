defmodule Fruitbot do
  @moduledoc """
  Documentation for `Fruitbot`.
  """

  def start(_type, _args) do
    Fruitbot.Supervisor.start_link(name: Fruitbot.Supervisor)
  end
end
