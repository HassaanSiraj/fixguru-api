class ProviderProfile < ApplicationRecord
  belongs_to :user

  has_one_attached :cnic_photo
  has_one_attached :profile_picture

  # Validations
  validates :full_name, presence: true
  validates :cnic_number, presence: true, uniqueness: true
  validates :skills, presence: true
  validates :service_areas, presence: true
  validates :verification_status, inclusion: { in: %w[pending approved rejected] }

  # Scopes
  scope :approved, -> { where(verification_status: 'approved') }
  scope :pending, -> { where(verification_status: 'pending') }

  # Methods
  def approved?
    verification_status == 'approved'
  end

  def pending?
    verification_status == 'pending'
  end
end
