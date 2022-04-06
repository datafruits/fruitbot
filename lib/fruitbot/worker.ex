defmodule Fruitbot.Worker do
  use GenServer

  alias PhoenixClient.{Socket, Channel, Message}

  def start_link(_opts) do
    IO.puts "starting worker..."
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    socket_opts = [
      url: System.get_env("CHAT_URL")
    ]

    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    wait_until_connected(socket)

    {:ok, _response, channel} = Channel.join(socket, "rooms:lobby")
    # set username here?
    Channel.push(channel, "authorize", %{user: "coach"})
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

  # defp get_state, do: GenServer.call(__MODULE__, :get_state)
  #
  # def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_cast({:send_discord_msg, msg}, state) do
    IO.puts "sending discord msg to datafruits chat..."
    IO.puts inspect state
    { :ok, message } = Channel.push(state.channel, "new:msg", %{user: "coach", body: "New msg in discord from #{msg.author.username}: #{msg.content}", timestamp: :os.system_time(:millisecond)})
    {:noreply, state}
  end

  def handle_info(%Message{payload: payload}, state) do
    IO.puts "Incoming Message: #{inspect payload}"
    {:noreply, state}
  end
end
