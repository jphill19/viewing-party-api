class ApplicationController < ActionController::API

  def authenticate_user
    key.requests.headers["Authorization"]

    @user = User.find_by(api_key: :key)

    if @user.nil?
      render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end
end
