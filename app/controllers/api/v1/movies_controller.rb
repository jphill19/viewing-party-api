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
    json_data = JSON.parse(response.body, symbolize_names: true)
    formatted_movies = format_api(json_data)

    render json: { data: formatted_movies}
  end

  def show
    id = params[:id]
    
    # Movie Detials
    details_endpoint = "/3/movie/#{id}"
    conn = Faraday.new(url: "https://api.themoviedb.org") do |faraday|
      faraday.headers["Authorization"] = Rails.application.credentials.tmdb[:api_key_auth]
    end

    response_details = conn.get(details_endpoint)
    movie_details = JSON.parse(response_details.body, symbolize_names: true)

    until response_details.success?
      render json: ErrorSerializer.format_error(ErrorMessage.new(movie_details[:status_message], 400)), status: :bad_request
      return
    end

    # Movies Cast
    credits_endpoint = "/3/movie/#{id}/credits"
    response_credits = conn.get(credits_endpoint)
    credits_data = JSON.parse(response_credits.body, symbolize_names: true)

    unless response_credits.success?
      render json: ErrorSerializer.format_error(ErrorMessage.new(credits_data[:status_message], 400)), status: :bad_request
      return
    end

    # Movies Reviews
    reviews_endpoint = "/3/movie/#{id}/reviews"
    response_reviews = conn.get(reviews_endpoint)
    reviews_data = JSON.parse(response_reviews.body, symbolize_names: true)

    unless response_reviews.success?
      render json: ErrorSerializer.format_error(ErrorMessage.new(credits_data[:status_message], 400)), status: :bad_request
      return
    end

    formatted_movie = format_movie_details(movie_details, credits_data, reviews_data)
    render json: { data: formatted_movie }
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

  def convert_minutes_to_runtime(minutes)
    time = Time.new(0) + (minutes * 60)
    hours = time.hour
    remaining_minutes = time.min
  
    runtime = "#{hours} hours, #{remaining_minutes} minutes"
    runtime
  end

  def format_movie_details(movie_details, credit_details, reviews_details)
   
    {
      id: movie_details[:id],
      type: "movie",
      attributes: {
        title: movie_details[:title],
        release_year: Date.parse(movie_details[:release_date]).year,
        vote_average: movie_details[:vote_average],
        runtime: convert_minutes_to_runtime(movie_details[:runtime]),
        genres: movie_details[:genres].map { |genre| genre[:name] },
        summary: movie_details[:overview],
        cast: credit_details[:cast].first(10).map { |cast| { character: cast[:character], actor: cast[:name] } },
        total_reviews: reviews_details[:total_results],
        reviews: reviews_details[:results].first(5).map { |review| { author: review[:author], review: review[:content]}}
      }
    }
  end

end