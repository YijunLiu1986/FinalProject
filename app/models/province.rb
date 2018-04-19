class Province < ApplicationRecord
  has_many :customer

  validates :PST, numericality: true
  validates :GST, numericality: true
  validates :HST, numericality: true
end
