defmodule Fruitbot.StreampusherApi do
  @moduledoc """
  Functions called by user commands from the Datafruits chat.
  """

  @spec user_search(String.t()) :: String.t()
  def user_search(query) do
    case HTTPoison.get!("https://datafruits.streampusher.com/api/djs/#{query}.json?name=#{query}") do
      %HTTPoison.Response{status_code: 200, body: body} ->
        response = Jason.decode!(body)
        data = response["data"]
        username = data["attributes"]["username"]
        url = "https://datafruits.fm/djs/#{username}"
        { url, username }

      %HTTPoison.Response{status_code: 404} ->
        error_message = "#{query} not found"
        { :error, error_message }

      _ ->
        "Whoops must have eaten a bad fruit"

        # %HTTPoison.Error{reason: reason} ->
        #   IO.inspect(reason)
    end
  end

  @spec tag_search(String.t()) :: String.t()
  def tag_search(query) do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/api/archives.json?tags=#{query}") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          response = Jason.decode!(body)

          data = response["data"]
          first_result = Enum.at(data, 0)
          slug = Kernel.get_in(first_result, ["attributes", "slug"])
          show_series_slug = Kernel.get_in(first_result, ["attributes", "show_series_slug"])
          url = "https://datafruits.fm/wiki/#{slug}"

          "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"

        %HTTPoison.Response{status_code: 404} ->
          "couldn't find any archives tagged with #{query}. musta been the onion salad dressing."

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end
  end

  @spec wiki_search(String.t()) :: String.t()
  def wiki_search(query) do
    case HTTPoison.get!("https://datafruits.streampusher.com/api/wiki_pages.json?q=#{query}") do
      %HTTPoison.Response{status_code: 200, body: body} ->
        response = Jason.decode!(body)
        data = response["data"]
        first_result = Enum.at(data, 0)
        slug = Kernel.get_in(first_result, ["attributes", "slug"])
        title = Kernel.get_in(first_result, ["attributes", "title"])
        url = "https://datafruits.fm/wiki/#{slug}"

        "Datafruits has what you're looking for. Check out the Fruitstopiyeah wiki article #{title} at :link: #{url}"

      # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
      %HTTPoison.Response{status_code: 404} ->
        "#{query} not found in the Fruitstopiyeah wiki. Maybe you should add it? https://datafruits.fm/wiki/new"

      _ ->
        "Whoops must have eaten a bad fruit"

        # %HTTPoison.Error{reason: reason} ->
        #   IO.inspect(reason)
    end
  end

  @spec current_shrimpos() :: String.t()
  def current_shrimpos do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/api/shrimpos.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end
    data = response["data"]
    # get list of shrimpos
    #
    # current
    #
    # voting
    current_shrimpos = Enum.filter(response["data"], fn s -> Kernel.get_in(s, ["attributes", "status"]) == "running" end)
    voting_shrimpos = Enum.filter(response["data"], fn s -> Kernel.get_in(s, ["attributes", "status"]) == "voting" end)
    current_shrimpos = for shrimpo <- current_shrimpos do
      # calculate time left
      end_at = Kernel.get_in(shrimpo, ["attributes", "end_at"])
      countdown = Fruitbot.Countdown.time_left end_at
      #
      # calculate URL
      slug = Kernel.get_in(shrimpo, ["attributes", "slug"])
      url = "https://datafruits.fm/shrimpos/#{slug}"
      %{title: shrimpo["attributes"]["title"], url: url, countdown: countdown, end_at: end_at, image: shrimpo["attributes"]["cover_art_url"]}
    end
    shrimpo_strings = Enum.map(current_shrimpos, fn shrimpo ->
      "#{shrimpo[:title]} ends in #{shrimpo[:countdown][:days]} days, #{shrimpo[:countdown][:hours]} hours, #{shrimpo[:countdown][:minutes]} minutes (#{shrimpo[:end_at]})! :link: #{shrimpo[:url]} #{shrimpo[:image]}"
    end)
    "Current Shrimpos: \n #{Enum.join(shrimpo_strings, "\n")}"
  end

  @spec current_show() :: String.t()
  def current_show do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/scheduled_shows/current.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end

    data = response["data"]
    title = Kernel.get_in(data, ["attributes", "title"])
    host = Kernel.get_in(data, ["attributes", "hosted_by"])
    description = Kernel.get_in(data, ["attributes", "description"])

    slug = Kernel.get_in(data, ["attributes", "slug"])
    show_series_slug = Kernel.get_in(data, ["attributes", "show_series_slug"])
    url = "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"
    image_url = Kernel.get_in(data, ["attributes", "thumb_image_url"])

    "Current show is #{title}, hosted by #{host}! Description: #{description}. :link: #{url} #{image_url}"
  end

  @spec next_show() :: String.t()
  def next_show do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/scheduled_shows/next.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end

    data = response["data"]
    start = Kernel.get_in(data, ["attributes", "start"])
    countdown = Fruitbot.Countdown.time_left start

    title = Kernel.get_in(data, ["attributes", "title"])
    host = Kernel.get_in(data, ["attributes", "hosted_by"])
    description = Kernel.get_in(data, ["attributes", "description"])
    slug = Kernel.get_in(data, ["attributes", "slug"])
    show_series_slug = Kernel.get_in(data, ["attributes", "show_series_slug"])
    url = "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"
    image_url = Kernel.get_in(data, ["attributes", "thumb_image_url"])
    "Next show is #{title}, hosted by #{host}! Beginning in #{countdown[:days]} days, #{countdown[:hours]} hours, #{countdown[:minutes]} minutes . Description: #{description}. :link: #{url} #{image_url}"
  end

  @spec latest_archive() :: String.t()
  def latest_archive do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/api/archives.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          response = Jason.decode!(body)

          data = response["data"]
          first_result = Enum.at(data, 0)
          slug = Kernel.get_in(first_result, ["attributes", "slug"])
          show_series_slug = Kernel.get_in(first_result, ["attributes", "show_series_slug"])
          url = "https://datafruits.fm/wiki/#{slug}"

          "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end
  end
end
