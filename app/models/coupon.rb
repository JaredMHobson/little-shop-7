class Coupon < ApplicationRecord
  enum :status, [:disabled, :enabled], validate: true
  enum :coupon_type, [:percent, :dollar], validate: true

  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: true
end