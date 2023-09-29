defmodule Fruitbot do
  @moduledoc """
  Documentation for `Fruitbot`.
  """

  def start(_type, _args) do
    :ets.new(:user_bigups, [:named_table, :public])
    Fruitbot.Supervisor.start_link(name: Fruitbot.Supervisor)
  end
end
