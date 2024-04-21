class Coupon < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  enum :status, [:disabled, :enabled], validate: true
  enum :coupon_type, [:percent, :dollar], validate: true

  belongs_to :merchant
  has_many :invoices
  has_many :transactions, through: :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: true

  def count_usage
    transactions.where(result: 1).count
  end

  def has_pending_invoices?
    invoices.in_progress.count > 0
  end

  def formatted_amount
    if coupon_type == 'percent'
      number_to_percentage(amount, precision: 0)
    else
      number_to_currency(amount / 100.0)
    end
  end
end