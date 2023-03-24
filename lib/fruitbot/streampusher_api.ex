defmodule Fruitbot.StreampusherApi do
  def next_show do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/scheduled_shows/next.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)
        %HTTPoison.Response{status_code: 404} ->
          IO.puts("Not found")
        %HTTPoison.Error{reason: reason} ->
          IO.inspect(reason)
      end

      data = response["data"]
      title = Kernel.get_in(data, ["attributes", "title"])
      host = Kernel.get_in(data, ["attributes", "hosted_by"])
      description = Kernel.get_in(data, ["attributes", "description"])
      IO.puts("Next show is #{title}, hosted by #{host}! Description: #{description}.")
  end

  # def search_wiki(query) do
  #   response =
  #     case HTTPoison.get!("ttps://datafruits.streampusher.com/api/wiki_pages.json/?q/=#{query}") do
  #       ...
  # end

  # def today do
  #
  # end
end
