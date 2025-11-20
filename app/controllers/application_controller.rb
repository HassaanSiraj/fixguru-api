class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Rails.application.routes.url_helpers
  
  before_action :authenticate_request
  before_action :set_active_storage_url_options

  private

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: request.protocol,
      host: request.host,
      port: request.port
    }
  end

  def blob_url(attachment_or_blob)
    # Handle both ActiveStorage::Attachment and ActiveStorage::Blob
    blob = attachment_or_blob.is_a?(ActiveStorage::Attachment) ? attachment_or_blob.blob : attachment_or_blob
    return nil unless blob.present?
    # Construct the ActiveStorage URL manually
    "#{request.protocol}#{request.host_with_port}/rails/active_storage/blobs/#{blob.signed_id}/#{blob.filename}"
  end

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
