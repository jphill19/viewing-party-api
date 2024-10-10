class TmdbGateway
  def initialize()
    @conn = Faraday.new(url: "https://api.themoviedb.org") do |faraday|
      faraday.headers["Authorization"] = Rails.application.credentials.tmdb[:api_key_auth]
    end
  end

  def top_rated(query = nil)
     endpoint = "/3/movie/top_rated"

    if query
      endpoint = "3/search/movie?query=#{query}"
    end

    response = @conn.get(endpoint)
    JSON.parse(response.body, symbolize_names: true)
  end
  
  def movie_details(id)
    details_endpoint = "/3/movie/#{id}"
    response_details = @conn.get(details_endpoint)
    JSON.parse(response_details.body, symbolize_names: true)
  end

  def movie_cast(id)
    credits_endpoint = "/3/movie/#{id}/credits"
    response_credits = @conn.get(credits_endpoint)
    JSON.parse(response_credits.body, symbolize_names: true)
  end

  def movie_reviews(id)
    reviews_endpoint = "/3/movie/#{id}/reviews"
    response_reviews = @conn.get(reviews_endpoint)
    JSON.parse(response_reviews.body, symbolize_names: true)
  end

  def show_action(id)
    details_data = movie_details(id)
    if details_data[:success] == false
      return details_data[:status_message]
    end
    cast_data = movie_cast(id)
    credits_data = movie_reviews(id)

    MovieData.new(details_data, cast_data, credits_data)
  end
end