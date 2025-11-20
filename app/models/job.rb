class Job < ApplicationRecord
  belongs_to :user
  belongs_to :category
  belongs_to :assigned_provider, class_name: 'User', foreign_key: 'assigned_provider_id', optional: true

  has_many :bids, dependent: :destroy
  has_many_attached :images

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :location, presence: true
  validates :status, inclusion: { in: %w[open assigned completed] }
  validates :budget, numericality: { greater_than: 0 }, allow_nil: true

  # Scopes
  scope :open, -> { where(status: 'open') }
  scope :assigned, -> { where(status: 'assigned') }
  scope :completed, -> { where(status: 'completed') }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def open?
    status == 'open'
  end

  def assigned?
    status == 'assigned'
  end

  def completed?
    status == 'completed'
  end

  def assign_provider!(provider)
    update!(assigned_provider: provider, status: 'assigned')
    bids.where(user: provider).update_all(status: 'accepted')
    bids.where.not(user: provider).update_all(status: 'rejected')
  end
end
