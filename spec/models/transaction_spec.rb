require "rails_helper"

RSpec.describe Transaction, type: :model do
  before :each do
    @transaction = FactoryBot.create(:transaction)
  end
  describe "relationships" do
    it { should belong_to(:invoice) }
    it { should have_one(:customer).through(:invoice) }
    it { should have_one(:coupon).through(:invoice) }
    it { should have_many(:invoice_items).through(:invoice) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
  end

  describe "enums" do
    it { should define_enum_for(:result).with_values({ failed: 0, success: 1 }) }
  end

  describe "validations" do
    it { should validate_presence_of(:credit_card_number) }
    it { should validate_presence_of(:credit_card_expiration_date) }
  end
end