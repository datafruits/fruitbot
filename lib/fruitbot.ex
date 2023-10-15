defmodule Fruitbot do
  @moduledoc """
  Documentation for `Fruitbot`.
  """

  def start(_type, _args) do
    PersistentEts.new(:user_bigups, "bigups.tab", [:named_table, :public])
    Fruitbot.Supervisor.start_link(name: Fruitbot.Supervisor)
  end
end
