class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = JsonWebToken.decode(header)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  rescue JWT::DecodeError => e
    render json: { errors: 'Invalid token' }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def require_admin
    render json: { error: 'Unauthorized' }, status: :forbidden unless current_user&.admin?
  end

  def require_provider
    render json: { error: 'Unauthorized' }, status: :forbidden unless current_user&.provider?
  end

  def require_seeker
    render json: { error: 'Unauthorized' }, status: :forbidden unless current_user&.seeker?
  end
end
