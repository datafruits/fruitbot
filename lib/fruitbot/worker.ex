defmodule Fruitbot.Worker do
  use Slipstream,
    restart: :permanent

  require Logger

  @topic "rooms:lobby"

  @interval 120 * 60 * 1000

  def start_link(args) do
    Slipstream.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Slipstream
  def init(config) do
    Process.send_after(self(), :send_periodic_message, @interval)
    {:ok, connect!(config)}
  end

  @impl Slipstream
  def handle_connect(socket) do
    IO.puts('handle_connect')

    # socket =
    #   if Map.get(socket.assigns, :interval_started) do
    #     socket
    #   else
    #     :timer.send_interval(@interval, :send_periodic_message)
    #     assign(socket, :interval_started, true)
    #   end

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
  def handle_info(:send_periodic_message, socket) do
    # Customize this message however you want
    msg =
        "Enjoying the stream, Brendon? The best way to support is with a monthly donation on Patreon. Learn more at https://datafruits.fm/support. Or you could give :duckle: some fruit tickets"
    send_message(socket, msg)

    # Schedule the next one
    Process.send_after(self(), :send_periodic_message, @interval)

    {:noreply, socket}
  end


  @impl true
  def handle_cast({:send_discord_msg, msg}, socket) do
    IO.puts("sending discord msg to datafruits chat...")
    IO.puts(inspect(socket))
    IO.puts(inspect(msg.author))
    IO.puts(inspect(msg))

    avatar_url = Nostrum.Struct.User.avatar_url(msg.author)
    username = msg.author.username

    cond do
      # Stickers take priority if present
      msg.sticker_items && msg.sticker_items != [] ->
        sticker_id = List.first(msg.sticker_items).id
        content = "https://cdn.discordapp.com/stickers/#{sticker_id}.png"
        message = "New msg in discord from #{username}: #{content}"
        send_message(socket, message, avatar_url)

      # Attachments (images, files, etc.)
      msg.attachments && msg.attachments != [] ->
        # Collect all attachment URLs
        urls = Enum.map(msg.attachments, fn att -> att.url end)
        # Join with line breaks or spaces
        urls_text = Enum.join(urls, "\n")
        content =
          case msg.content do
            "" -> urls_text
            text -> text <> "\n" <> urls_text
          end

        message = "New msg in discord from #{username}: #{content}"
        send_message(socket, message, avatar_url)

      # Fallback: just text content
      true ->
        content = msg.content
        message = "New msg in discord from #{username}: #{content}"
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

      # case Fruitbot.Commands.handle_message(message["body"]) do
      # ignore bots
        if(message["role"] != "bot" && String.starts_with?(message["body"], "!")) do
        case Fruitbot.CommandHandler.handle_command(message["body"]) do
          {:ok, message} ->
            send_message(socket, message)

          {:error, :bad_command} ->
            # {:ok, model} = Markov.load("./coach_model", sanitize_tokens: true, store_log: [:train])
            # :ok = Markov.train(model, message["body"])
            # Markov.unload(model)
            # noop
            IO.puts("Coach doesn't understand this command. Try another!")
            :ignore
        end
      end
    end

    {:ok, socket}
  end

  # handle disconnects
  @impl Slipstream
  def handle_disconnect(_reason, socket) do
    IO.puts "DISCONNECTED ------------------ disconnected from phoenix"
    case reconnect(socket) do
      {:ok, socket} -> {:ok, socket}
      {:error, reason} ->
        IO.puts "ERROR -------------------------------------- error reconnecting: #{reason}"
        {:stop, reason, socket}
    end
  end

  @impl Slipstream
  def handle_topic_close(topic, _reason, socket) do
    rejoin(socket, topic)
  end
end
