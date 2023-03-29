defmodule Fruitbot.Commands do
  def handle_message(payload) do
    IO.inspect(payload)
    [command | tail] = String.split(payload)
    query = Enum.join(tail)

    case command do
      "!vr" ->
        msg =
          "Join the party in VR here! https://hubs.mozilla.com/MsvfAkH/terrific-satisfied-area"

        {:ok, msg}

      "!donate" ->
        msg =
          "Enjoying the stream? The best way to support is with a monthly donation on ampled. https://www.ampled.com/artist/datafruits You can also make a one time donation to our paypal. https://paypal.me/datafruitsfm"

        {:ok, msg}

      # TODO would it be fun to have !advice randomly draw from the datafruits marquee or something? I mean I like the cheese cow advice but everytime
      "!advice" ->
        msg = "Don't live like me Brendon. Don't get a tattoo of a cheese cow."
        {:ok, msg}

      "!sorry" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/onion_salad_dressing.mp3"])

        msg =
          "Must have been the onion salad dressing. Right, Brendon? :sorrymusthavebeentheonionsaladdressing:"

        {:ok, msg}

      "!thisisamazing" ->
        # shell to mplayer
        msg = "It's just a website"
        {:ok, msg}

      "!next" ->
        next_show = Fruitbot.StreampusherApi.next_show()
        {:ok, next_show}

      # "!wiki" ->
      #   wiki_link = Fruitbot.StreampusherApi.search_wiki(query)
      #   { :ok, wiki_link }

      _ ->
        IO.puts("unhandled command: #{command}")
        {:error}
    end
  end
end
