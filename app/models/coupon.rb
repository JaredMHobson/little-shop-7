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

  def self.enabled_sorted_by_popularity
    enabled.left_outer_joins(:transactions).select('coupons.*, COUNT(CASE WHEN transactions.result = 1 then 1 end) AS total_count').group(:id).order(total_count: :desc, id: :asc)
  end

  def self.disabled_sorted_by_popularity
    disabled.left_outer_joins(:transactions).select('coupons.*, COUNT(CASE WHEN transactions.result = 1 then 1 end) AS total_count').group(:id).order(total_count: :desc, id: :asc)
  end
end
