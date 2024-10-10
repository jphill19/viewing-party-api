class Api::V1::EventsController < ApplicationController
  # before_action :authenticate_user
  before_action :authenticate_user_api_key

  def create
    invitees = params["invitees"]
    # @event = Event.new(event_params)

    valid_invitees = User.where(id: invitees)
    
    if valid_invitees.size != invitees.size
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Some invitees do not exist", 422)), status: :unprocessable_entity
    end

    # user = User.find_by(api_key: event.api_key)
    # binding.pry
    # if user.nil?
    #   return render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    # end

  end

  private

  def event_params
    params.require(:event).permit(
      :name,
      :start_time,
      :end_time,
      :movie_id,
      :movie_title,
      :api_key,
    )
  end

  def authenticate_user_api_key
    @event = Event.new(event_params)
    user = User.find_by(api_key: @event.api_key)
    if user.nil?
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end

end