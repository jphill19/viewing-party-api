class Api::V1::MoviesController < ApplicationController
  def index
    tmbd_gateway = TmdbGateway.new
    if params[:query].present?
      data = tmbd_gateway.top_rated(params[:query])
    else
      data = tmbd_gateway.top_rated
    end
    render json: TmdbSerializer.format_top_rated(data)
  end

  def show
    id = params[:id]
    tmdb_gateway = TmdbGateway.new
    data = tmdb_gateway.show_action(id)

    if data.is_a?(String)
      return render json: ErrorSerializer.format_error(ErrorMessage.new(data,400)), status: :bad_request
    end

    render json: TmdbSerializer.format_show_movie(data)
  end

end