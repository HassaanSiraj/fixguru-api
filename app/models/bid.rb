class Bid < ApplicationRecord
  belongs_to :job
  belongs_to :user

  # Validations
  validates :proposed_cost, presence: true, numericality: { greater_than: 0 }
  validates :proposal_message, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { in: %w[pending accepted rejected] }
  validates :user_id, uniqueness: { scope: :job_id, message: 'has already placed a bid on this job' }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }

  # Methods
  def pending?
    status == 'pending'
  end

  def accepted?
    status == 'accepted'
  end

  def rejected?
    status == 'rejected'
  end
end
