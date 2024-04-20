require "rails_helper"

RSpec.describe Coupon, type: :model do

  before(:each) do
    @coupon = create(:coupon)
  end

  describe "relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:amount) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_numericality_of(:amount) }
  end
end