class Api::V1::EventsController < ApplicationController

  before_action :authenticate_user_api_key, only: [:create]
  before_action :validate_key_for_update, only: [:add_user]

  def create
    invitees = params["invitees"]
    valid_invitees = User.where(id: invitees)

    if valid_invitees.size != invitees.size
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Some invitees do not exist", 422)), status: :unprocessable_entity
    end

    runtime = TmdbGateway.return_runtime_if_data_is_valid(event_params)
    if runtime.is_a?(ErrorMessage)

      return render json: ErrorSerializer.format_error(runtime), status: runtime.status_code
    end
    event = Event.new(event_params.merge(movie_length: runtime))

    if event.save
      valid_invitees.each do |user|
        EventInvitation.create!(event: event, user: user)
      end

      render json: EventSerializer.new(event), status: :created
    else
      error_message = ErrorMessage.new(event.errors.full_messages.join(', '), 422)
      render json: ErrorSerializer.format_error(error_message), status: :unprocessable_entity
    end

  end

  def add_user
    user_id = params["invitees_user_id"]
    user = User.find(user_id)
    EventInvitation.create!(event: @event, user: user)
    render json: EventSerializer.new(@event), status: :ok
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
    user = User.find_by(api_key: params[:api_key])
    if user.nil?
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end

  def validate_key_for_update
    @event = Event.find(params[:id])
    if @event.api_key != params[:api_key]
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end
end