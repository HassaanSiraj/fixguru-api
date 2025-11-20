class Subscription < ApplicationRecord
  belongs_to :user
  has_many :payments, dependent: :destroy

  # Validations
  validates :plan_type, presence: true, inclusion: { in: %w[free standard pro] }
  validates :status, inclusion: { in: %w[active expired cancelled] }

  # Scopes
  scope :active, -> { where(status: 'active').where('end_date IS NULL OR end_date >= ?', Date.current) }
  scope :expired, -> { where(status: 'expired').or(where('end_date < ?', Date.current)) }

  # Callbacks
  before_create :set_dates_for_free_plan

  # Methods
  def active?
    status == 'active' && (end_date.nil? || end_date >= Date.current)
  end

  def expired?
    !active?
  end

  def free?
    plan_type == 'free'
  end

  def standard?
    plan_type == 'standard'
  end

  def pro?
    plan_type == 'pro'
  end

  def plan_price
    case plan_type
    when 'free'
      0
    when 'standard'
      1000
    when 'pro'
      2000
    else
      0
    end
  end

  private

  def set_dates_for_free_plan
    if plan_type == 'free'
      self.start_date ||= Date.current
      self.status ||= 'active'
    end
  end
end
