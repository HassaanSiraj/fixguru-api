class Payment < ApplicationRecord
  belongs_to :subscription

  has_one_attached :payment_proof

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true, inclusion: { in: %w[payfast bank_transfer] }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }

  # Methods
  def pending?
    status == 'pending'
  end

  def approved?
    status == 'approved'
  end

  def approve!
    update!(status: 'approved')
    subscription.update!(status: 'active', start_date: Date.current, end_date: Date.current + 1.month)
  end

  def reject!
    update!(status: 'rejected')
  end
end
