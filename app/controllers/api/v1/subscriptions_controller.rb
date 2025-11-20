class Api::V1::SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show]

  def index
    subscriptions = current_user.subscriptions.order(created_at: :desc)
    render json: subscriptions.as_json(include: :payments), status: :ok
  end

  def show
    render json: @subscription.as_json(include: :payments), status: :ok
  end

  def create
    subscription = current_user.subscriptions.build(subscription_params)
    subscription.status = 'active'
    subscription.start_date = Date.current
    subscription.end_date = Date.current + 1.month unless subscription.free?

    if subscription.save
      render json: subscription, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def current
    subscription = current_user.current_subscription
    if subscription
      render json: subscription.as_json(include: :payments), status: :ok
    else
      render json: { error: 'No active subscription' }, status: :not_found
    end
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Subscription not found' }, status: :not_found
  end

  def subscription_params
    params.require(:subscription).permit(:plan_type)
  end
end

