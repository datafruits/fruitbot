defmodule Fruitbot.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      #{PhoenixClient.Socket, {socket_opts, name: PhoenixClient.Socket}},
      Plug.Cowboy.child_spec(scheme: :http, plug: Fruitbot.Router, options: [port: System.get_env("PORT") || 4000]),
      {Fruitbot.Worker, name: Fruitbot.Worker},
      {Fruitbot.NostrumConsumer, name: Fruitbot.NostrumConsumer}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
