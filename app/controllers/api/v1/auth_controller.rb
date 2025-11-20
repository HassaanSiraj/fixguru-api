class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  def register
    user = User.new(user_params)
    user.status = 'active'

    if user.save
      # Create free subscription for new users
      user.subscriptions.create!(plan_type: 'free', status: 'active', start_date: Date.current)

      # Create provider profile if provider
      if user.provider?
        user.build_provider_profile(
          verification_status: 'pending'
        ).save
      end

      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        user: user.as_json(except: [:password_digest]),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        user: user.as_json(except: [:password_digest]),
        token: token
      }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def me
    render json: current_user.as_json(
      except: [:password_digest],
      include: {
        provider_profile: {
          include: {
            cnic_photo: { methods: [:url] },
            profile_picture: { methods: [:url] }
          }
        },
        current_subscription: {}
      }
    ), status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end

