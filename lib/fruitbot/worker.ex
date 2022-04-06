defmodule Fruitbot.Worker do
  use GenServer

  alias PhoenixClient.{Socket, Channel, Message}

  def start_link(_opts) do
    IO.puts "starting worker..."
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    socket_opts = [
      url: "ws://localhost:4000/socket/websocket"
    ]

    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    wait_until_connected(socket)

    {:ok, _response, channel} = Channel.join(socket, "rooms:lobby")
    {:ok, %{
      channel: channel
    }}
  end

  defp wait_until_connected(socket) do
    if !PhoenixClient.Socket.connected?(socket) do
      Process.sleep(100)
      wait_until_connected(socket)
    end
  end

  def handle_info(%Message{payload: payload}, state) do
    IO.puts "Incoming Message: #{inspect payload}"
    {:noreply, state}
  end
end
