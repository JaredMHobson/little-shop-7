class Transaction < ApplicationRecord
  enum :result, [:failed, :success], validate: true

  belongs_to :invoice
  has_one :customer, through: :invoice
  has_one :coupon, through: :invoice
  has_many :invoice_items, through: :invoice
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  validates :credit_card_number, presence: true 
  validates :credit_card_expiration_date, presence: true 
end
