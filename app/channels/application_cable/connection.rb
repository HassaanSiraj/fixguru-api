module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token] || extract_token_from_header
      decoded = JsonWebToken.decode(token)
      
      if decoded
        User.find(decoded[:user_id])
      else
        reject_unauthorized_connection
      end
    rescue ActiveRecord::RecordNotFound
      reject_unauthorized_connection
    end

    def extract_token_from_header
      header = request.headers['Authorization']
      header&.split(' ')&.last
    end
  end
end
