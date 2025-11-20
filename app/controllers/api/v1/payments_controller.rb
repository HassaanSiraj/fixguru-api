class Api::V1::PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :update]

  def index
    payments = Payment.joins(:subscription).where(subscriptions: { user_id: current_user.id })
    render json: payments.as_json(include: :subscription), status: :ok
  end

  def show
    render json: @payment.as_json(
      include: {
        subscription: {},
        payment_proof: { methods: [:url] }
      }
    ), status: :ok
  end

  def create
    subscription = current_user.subscriptions.find(params[:subscription_id])
    
    payment = subscription.payments.build(payment_params)
    payment.status = 'pending'

    if payment.save
      # Attach payment proof if provided
      if params[:payment_proof].present?
        payment.payment_proof.attach(params[:payment_proof])
      end

      render json: payment.as_json(
        include: {
          payment_proof: { methods: [:url] }
        }
      ), status: :created
    else
      render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # Only allow updating payment proof for pending payments
    if @payment.status != 'pending' && !current_user.admin?
      render json: { error: 'Cannot update non-pending payment' }, status: :forbidden
      return
    end

    if params[:payment_proof].present?
      @payment.payment_proof.attach(params[:payment_proof])
    end

    if @payment.update(payment_params.except(:payment_proof))
      render json: @payment, status: :ok
    else
      render json: { errors: @payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_payment
    @payment = Payment.joins(:subscription).where(subscriptions: { user_id: current_user.id }).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Payment not found' }, status: :not_found
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_method, :transaction_id)
  end
end

