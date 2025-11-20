class Category < ApplicationRecord
  has_many :jobs, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
