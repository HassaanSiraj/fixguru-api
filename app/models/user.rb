class User < ApplicationRecord
  has_secure_password

  # Associations
  has_one :provider_profile, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id', dependent: :destroy
  has_many :assigned_jobs, class_name: 'Job', foreign_key: 'assigned_provider_id', dependent: :nullify

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[service_seeker service_provider admin] }
  validates :status, inclusion: { in: %w[active inactive] }, allow_nil: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :providers, -> { where(role: 'service_provider') }
  scope :seekers, -> { where(role: 'service_seeker') }

  # Methods
  def admin?
    role == 'admin'
  end

  def provider?
    role == 'service_provider'
  end

  def seeker?
    role == 'service_seeker'
  end

  def active_provider?
    provider? && status == 'active' && provider_profile&.verification_status == 'approved'
  end

  def current_subscription
    subscriptions.active.order(created_at: :desc).first
  end

  def can_bid?
    return false unless active_provider?
    subscription = current_subscription
    return true if subscription&.plan_type == 'pro'
    return false unless subscription

    plan_type = subscription.plan_type
    bids_today = bids.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count

    case plan_type
    when 'free'
      bids_today < 2
    when 'standard'
      bids_today < 20
    else
      false
    end
  end

  def remaining_bids_today
    subscription = current_subscription
    return 0 unless subscription

    bids_today = bids.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count

    case subscription.plan_type
    when 'free'
      [2 - bids_today, 0].max
    when 'standard'
      [20 - bids_today, 0].max
    when 'pro'
      Float::INFINITY
    else
      0
    end
  end
end
