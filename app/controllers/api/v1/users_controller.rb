class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user_api_key_header, only: [:show]


  def create
    user = User.new(user_params)
    if user.save
      render json: UserSerializer.new(user), status: :created
    else
      render json: ErrorSerializer.format_error(ErrorMessage.new(user.errors.full_messages.to_sentence, 400)), status: :bad_request
    end
  end

  def index
    render json: UserSerializer.format_user_list(User.all)
  end

  def show
    hosted_parties = Event.where(api_key: @current_user.api_key)
    parties_invited = @current_user.parties_invited

    serialized_data = UserSerializer.new(@current_user, params: {
      hosted_parties: hosted_parties,
      parties_invited: parties_invited,
      current_user_id: @current_user.id,
      exclude_api_key: true
    }).serializable_hash

    render json: serialized_data, status: :ok
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end

  def authenticate_user_api_key_header
    key = request.headers["Authorization"]
    @current_user = User.find(params[:id])
    if @current_user.api_key != key
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end
end