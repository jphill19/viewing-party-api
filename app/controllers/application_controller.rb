class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  private

  def authenticate_user
    key.requests.headers["Authorization"]

    @user = User.find_by(api_key: :key)

    if @user.nil?
      render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end

  def record_not_found(exception)
    render json: ErrorSerializer.format_error(ErrorMessage.new(exception.message, 404)), status: :not_found
  end

  def record_not_unique(exception)
    render json: ErrorSerializer.format_error(ErrorMessage.new("Duplicate record: This record already exist", 409)), status: :conflict
  end
end
