class Api::V1::AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    stats = {
      total_users: User.count,
      total_providers: User.providers.count,
      total_seekers: User.seekers.count,
      pending_providers: ProviderProfile.pending.count,
      total_jobs: Job.count,
      open_jobs: Job.open.count,
      total_bids: Bid.count,
      active_subscriptions: Subscription.active.count,
      pending_payments: Payment.pending.count
    }

    render json: stats, status: :ok
  end

  def approve_provider
    profile = ProviderProfile.find(params[:id])
    profile.update!(verification_status: 'approved')
    profile.user.update!(status: 'active')

    render json: { message: 'Provider approved successfully' }, status: :ok
  end

  def reject_provider
    profile = ProviderProfile.find(params[:id])
    profile.update!(verification_status: 'rejected')

    render json: { message: 'Provider rejected' }, status: :ok
  end

  def approve_payment
    payment = Payment.find(params[:id])
    payment.approve!

    render json: { message: 'Payment approved successfully' }, status: :ok
  end

  def reject_payment
    payment = Payment.find(params[:id])
    payment.reject!

    render json: { message: 'Payment rejected' }, status: :ok
  end

  def pending_providers
    profiles = ProviderProfile.pending.includes(:user)
    render json: profiles.as_json(
      include: {
        user: { only: [:id, :email, :created_at] },
        cnic_photo: { methods: [:url] },
        profile_picture: { methods: [:url] }
      }
    ), status: :ok
  end

  def pending_payments
    payments = Payment.pending.includes(:subscription)
    render json: payments.as_json(
      include: {
        subscription: {
          include: {
            user: { only: [:id, :email] }
          }
        },
        payment_proof: { methods: [:url] }
      }
    ), status: :ok
  end
end

