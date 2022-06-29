defmodule Fruitbot.StreampusherApi do
  def next_show do
    {:ok, resp} = :httpc.request(:get, {'https://datafruits.streampusher.com/scheduled_shows/next.json', []}, [], [body_format: :json])
    json = elem(resp, 2)
    {:ok, decoded } = Jason.decode(json)
    decoded["scheduled_show"]["tweet_content"]
  end

  # def today do
  #
  # end
end
