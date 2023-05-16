defmodule Fruitbot.UserNotificationWorker do
  use GenServer

  alias PhoenixClient.Socket
  alias PhoenixClient.Channel
  alias PhoenixClient.Message

  def start_link(_opts) do
    IO.puts("starting worker...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    socket_opts = [
      url: System.get_env("CHAT_URL")
    ]

    {:ok, socket} = Socket.start_link(socket_opts)
    wait_until_connected(socket)

    {:ok, _response, channel} = Channel.join(socket, "user_notifications")

    {:ok,
     %{
       channel: channel
     }}
  end

  defp wait_until_connected(socket) do
    if !PhoenixClient.Socket.connected?(socket) do
      Process.sleep(100)
      wait_until_connected(socket)
    end
  end

end
