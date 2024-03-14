defmodule Fruitbot.Worker do
  use Slipstream,
    restart: :temporary

  require Logger

  @topic "rooms:lobby"

  def start_link(args) do
    Slipstream.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Slipstream
  def init(config) do
    {:ok, connect!(config)}
  end

  @impl Slipstream
  def handle_connect(socket) do
    IO.puts('handle_connect')
    {:ok, join(socket, @topic)}
  end

  @impl Slipstream
  @spec handle_join(<<_::88>>, any, Slipstream.Socket.t()) :: {:ok, Slipstream.Socket.t()}
  def handle_join(@topic, _join_response, socket) do
    avatar_url = "https://cdn.discordapp.com/avatars/961310729644957786/888d15c8ee637d0793c8a733ca1dd981.webp?size=80"
    push(socket, @topic, "authorize", %{user: "coach", avatarUrl: avatar_url})
    IO.puts('handle_join')
    {:ok, socket}
  end

  @impl true
  def handle_cast({:send_discord_msg, msg}, socket) do
    IO.puts("sending discord msg to datafruits chat...")
    IO.puts(inspect(socket))
    IO.puts(inspect(msg.author))
    avatar_url = Nostrum.Struct.User.avatar_url(msg.author)

    # TODO msg.author.username is pulling from permanent discord username, not datafruits-specific username
    if msg.sticker_items do
      sticker_id = List.first(msg.sticker_items).id
      content ="https://cdn.discordapp.com/stickers/#{sticker_id}.png"
      message = "New msg in discord from #{msg.author.username}: #{content}"
      send_message(socket, message, avatar_url)
    else
      content = msg.content
      message = "New msg in discord from #{msg.author.username}: #{content}"
      send_message(socket, message, avatar_url)
    end
    {:noreply, socket}
  end

  defp send_message(
         socket,
         body,
         avatar_url \\ "https://cdn.discordapp.com/avatars/961310729644957786/888d15c8ee637d0793c8a733ca1dd981.webp?size=80"
       ) do
    channel_msg = %{
      user: "coach",
      body: body,
      timestamp: :os.system_time(:millisecond),
      bot: true,
      # change to user's url???
      avatarUrl: avatar_url
      # avatarUrl: avatar_url(avatar)
    }

    {:ok, message} = push(socket, @topic, "new:msg", channel_msg)
    {:ok, message}
  end

  @impl true
  def handle_message(@topic, event, message, socket) do
    IO.puts("Incoming Message: #{inspect(message)}")
    IO.puts(inspect({@topic, event, message}))

    if Map.has_key?(message, "body") do
      IO.puts("message body: #{message["body"]}")
      IO.puts("message role: #{message["role"]}")

      # save message for markov chain thingies

      case Fruitbot.Commands.handle_message(message["body"]) do
        {:ok, message} ->
          send_message(socket, message)

        {:error, :bad_command} ->
          # don't rain coach on himself
          if(message["role"] != "bot") do
            {:ok, model} = Markov.load("./coach_model", sanitize_tokens: true, store_log: [:train])
            :ok = Markov.train(model, message["body"])
            Markov.unload(model)
          end
          # noop
          IO.puts("Coach doesn't understand this command. Try another!")
          :ignore
      end
    end

    {:ok, socket}
  end

  # handle disconnects
  @impl Slipstream
  def handle_disconnect(_reason, socket) do
    case reconnect(socket) do
      {:ok, socket} -> {:ok, socket}
      {:error, reason} -> {:stop, reason, socket}
    end
  end

  @impl Slipstream
  def handle_topic_close(topic, _reason, socket) do
    rejoin(socket, topic)
  end
end
