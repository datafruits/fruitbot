defmodule Fruitbot.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  defp get_port() do
    port_env_variable = System.get_env("PORT")

    if is_nil(port_env_variable) do
      4000
    else
      String.to_integer(port_env_variable)
    end
  end

  @impl true
  def init(:ok) do
    [bot_config] = Application.fetch_env!(:fruitbot, :bots)

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Fruitbot.Router, options: [port: get_port()]),
      {Fruitbot.Worker, uri: System.get_env("CHAT_URL")},
      {Fruitbot.NostrumConsumer, name: Fruitbot.NostrumConsumer},
      {TMI.Supervisor, bot_config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
