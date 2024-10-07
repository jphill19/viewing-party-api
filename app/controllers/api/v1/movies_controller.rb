class Api::V1::MoviesController < ApplicationController
  def index
    conn = Faraday.new(url: "https://api.themoviedb.org") do |faraday|
      faraday.headers["Authorization"] = Rails.application.credentials.tmdb[:api_key_auth]
    end

    response = conn.get("/3/movie/top_rated")
    json = JSON.parse(response.body, symbolize_names: true)

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

    render json: { data: formatted_movies}
  end
end