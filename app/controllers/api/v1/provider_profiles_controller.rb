class Api::V1::ProviderProfilesController < ApplicationController
  before_action :require_provider
  before_action :set_provider_profile, only: [:show, :update]

  def show
    render json: @provider_profile.as_json(
      include: {
        cnic_photo: { methods: [:url] },
        profile_picture: { methods: [:url] }
      }
    ), status: :ok
  end

  def create
    @provider_profile = current_user.build_provider_profile(provider_profile_params)
    @provider_profile.verification_status = 'pending'

    if @provider_profile.save
      render json: @provider_profile.as_json(
        include: {
          cnic_photo: { methods: [:url] },
          profile_picture: { methods: [:url] }
        }
      ), status: :created
    else
      render json: { errors: @provider_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @provider_profile.update(provider_profile_params)
      render json: @provider_profile.as_json(
        include: {
          cnic_photo: { methods: [:url] },
          profile_picture: { methods: [:url] }
        }
      ), status: :ok
    else
      render json: { errors: @provider_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_provider_profile
    @provider_profile = current_user.provider_profile
    render json: { error: 'Profile not found' }, status: :not_found unless @provider_profile
  end

  def provider_profile_params
    params.require(:provider_profile).permit(:full_name, :cnic_number, :skills, :experience, :service_areas, :cnic_photo, :profile_picture)
  end
end

