class Api::V1::MoviesController < ApplicationController
  def index
    endpoint = "/3/movie/top_rated"
    
    if params[:query].present?
      query = params[:query]
      endpoint = "3/search/movie?query=#{query}"
    end
    
    conn = Faraday.new(url: "https://api.themoviedb.org") do |faraday|
      faraday.headers["Authorization"] = Rails.application.credentials.tmdb[:api_key_auth]
    end

    response = conn.get(endpoint)
    json = JSON.parse(response.body, symbolize_names: true)
    formatted_movies = format_api(json)

    render json: { data: formatted_movies}
  end

  private 

  def format_api(json)
    formatted_movies = json[:results].map do |movie|
      {
        id: movie[:id],
        type: "movie",
        attributes: {
          title: movie[:title],
          vote_average: movie[:vote_average]
        }
      }
    end
  end
end