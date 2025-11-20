class Api::V1::BidsController < ApplicationController
  before_action :require_provider
  before_action :set_bid, only: [:show, :update, :destroy]
  before_action :set_job, only: [:create]

  def index
    bids = current_user.bids.includes(:job, :user)
    bids = bids.where(job_id: params[:job_id]) if params[:job_id].present?
    bids = bids.where(status: params[:status]) if params[:status].present?

    render json: bids.as_json(
      include: {
        job: {
          include: {
            category: {},
            user: { only: [:id, :email] }
          }
        }
      }
    ), status: :ok
  end

  def show
    render json: @bid.as_json(
      include: {
        job: {
          include: {
            category: {},
            user: { only: [:id, :email] }
          }
        },
        user: {
          include: {
            provider_profile: {}
          }
        }
      }
    ), status: :ok
  end

  def create
    unless current_user.can_bid?
      render json: { 
        error: 'Cannot place bid. Check your subscription status or daily bid limit.',
        remaining_bids: current_user.remaining_bids_today
      }, status: :forbidden
      return
    end

    unless current_user.active_provider?
      render json: { error: 'Provider profile must be approved to place bids' }, status: :forbidden
      return
    end

    @bid = @job.bids.build(bid_params)
    @bid.user = current_user
    @bid.status = 'pending'

    if @bid.save
      render json: @bid.as_json(
        include: {
          job: {},
          user: {
            include: {
              provider_profile: { only: [:full_name] }
            }
          }
        }
      ), status: :created
    else
      render json: { errors: @bid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @bid.user_id != current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    if @bid.job.assigned?
      render json: { error: 'Cannot update bid for assigned job' }, status: :unprocessable_entity
      return
    end

    if @bid.update(bid_params)
      render json: @bid, status: :ok
    else
      render json: { errors: @bid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @bid.user_id != current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    if @bid.job.assigned?
      render json: { error: 'Cannot delete bid for assigned job' }, status: :unprocessable_entity
      return
    end

    @bid.destroy
    render json: { message: 'Bid deleted successfully' }, status: :ok
  end

  private

  def set_bid
    @bid = Bid.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Bid not found' }, status: :not_found
  end

  def set_job
    @job = Job.find(params[:job_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Job not found' }, status: :not_found
  end

  def bid_params
    params.require(:bid).permit(:proposed_cost, :proposal_message, :estimated_time)
  end
end

