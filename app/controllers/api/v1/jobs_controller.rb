class Api::V1::JobsController < ApplicationController
  before_action :set_job, only: [:show, :update, :destroy, :assign_provider]

  def index
    jobs = Job.includes(:user, :category, :bids)
    
    # Filters
    jobs = jobs.where(category_id: params[:category_id]) if params[:category_id].present?
    jobs = jobs.where(status: params[:status]) if params[:status].present?
    jobs = jobs.where('location ILIKE ?', "%#{params[:location]}%") if params[:location].present?
    
    # For providers, only show open jobs
    if current_user.provider?
      jobs = jobs.open
    end
    
    # For seekers, show their own jobs
    if current_user.seeker?
      jobs = jobs.where(user_id: current_user.id) if params[:my_jobs] == 'true'
    end

    jobs = jobs.recent.page(params[:page] || 1).per(params[:per_page] || 20)

    render json: {
      jobs: jobs.map do |job|
        job.as_json(
          include: {
            user: { only: [:id, :email] },
            category: { only: [:id, :name] },
            bids: {
              include: {
                user: { only: [:id, :email] }
              }
            }
          }
        ).merge(
          images: job.images.map { |img| blob_url(img) }
        )
      end,
      pagination: {
        page: jobs.current_page,
        per_page: jobs.limit_value,
        total_pages: jobs.total_pages,
        total_count: jobs.total_count
      }
    }, status: :ok
  end

  def show
    render json: @job.as_json(
      include: {
        user: { only: [:id, :email] },
        category: {},
        bids: {
          include: {
            user: {
              only: [:id, :email],
              include: {
                provider_profile: { only: [:full_name, :skills] }
              }
            }
          }
        },
        assigned_provider: {
          only: [:id, :email],
          include: {
            provider_profile: { only: [:full_name] }
          }
        }
      }
    ).merge(
      images: @job.images.map { |img| blob_url(img) }
    ), status: :ok
  end

  before_action :require_seeker, only: [:create, :assign_provider]

  def create
    @job = current_user.jobs.build(job_params)
    @job.status = 'open'

    if @job.save
      # Attach images if provided
      if params[:images].present?
        params[:images].each do |image|
          @job.images.attach(image)
        end
      end

      render json: {
        id: @job.id,
        title: @job.title,
        description: @job.description,
        category_id: @job.category_id,
        budget: @job.budget,
        location: @job.location,
        status: @job.status,
        user_id: @job.user_id,
        created_at: @job.created_at,
        updated_at: @job.updated_at,
        category: @job.category.as_json,
        images: @job.images.map { |img| blob_url(img) }
      }, status: :created
    else
      render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @job.user_id != current_user.id && !current_user.admin?
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    if @job.update(job_params)
      render json: @job, status: :ok
    else
      render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @job.user_id != current_user.id && !current_user.admin?
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    @job.destroy
    render json: { message: 'Job deleted successfully' }, status: :ok
  end

  def assign_provider
    provider = User.find(params[:provider_id])
    
    if @job.user_id != current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    @job.assign_provider!(provider)
    render json: @job, status: :ok
  end

  private

  def set_job
    @job = Job.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Job not found' }, status: :not_found
  end

  def job_params
    params.require(:job).permit(:title, :description, :category_id, :budget, :location)
  end
end

