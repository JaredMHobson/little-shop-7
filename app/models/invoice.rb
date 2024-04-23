class Invoice < ApplicationRecord
  enum :status, ['in progress', 'completed', 'cancelled'], validate: true

  belongs_to :customer
  belongs_to :coupon, optional: true
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  def self.incomplete_invoices
    joins(:invoice_items)
    .distinct
    .where.not(invoice_items: { status: 2 })
    .order(:created_at)
  end

  def formatted_date
    self.created_at.strftime("%A, %B %d, %Y")
  end

  def customer_name
    "#{customer.first_name} #{customer.last_name}"
  end

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def net_revenue
    total = total_revenue

    if coupon.nil?
      total
    elsif coupon.coupon_type == 'percent'
      total - coupon_savings
    else
      [(total - coupon.amount), 0].max
    end
  end

  def coupon_savings
    if coupon.nil?
      0
    elsif coupon.coupon_type == 'percent'
      (total_revenue_for_merchant(coupon.merchant)) * coupon.amount / 100.0
    else
      coupon.amount
    end
  end

  def total_revenue_for_merchant(merchant)
    items.where(merchant: merchant)
    .sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def net_revenue_for_merchant(merchant)
    total = total_revenue_for_merchant(merchant)

    if coupon.nil? || coupon.merchant != merchant
      total
    elsif coupon.coupon_type == 'percent'
      total - coupon_savings
    else
      [(total - coupon.amount), 0].max
    end
  end
end
