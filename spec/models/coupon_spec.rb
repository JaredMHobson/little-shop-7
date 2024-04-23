require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe 'relationships and validations' do
    before(:each) do
      @coupon = create(:coupon)
    end

    describe "relationships" do
      it { should belong_to(:merchant) }
      it { should have_many(:invoices) }
      it { should have_many(:transactions) }
    end

    describe "validations" do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:code) }
      it { should validate_presence_of(:amount) }
      it { should validate_uniqueness_of(:code) }
      it { should validate_numericality_of(:amount) }
    end
  end

  describe '#instance_methods' do
    describe '#count_usage' do
      it 'returns a count of the number of times a coupon was used on an invoice with a successful transaction' do
        merchant1 = create(:merchant)
        coupon1 = create(:coupon, merchant: merchant1)
        coupon2 = create(:coupon, merchant: merchant1)
  
        invoice1 = create(:invoice, coupon: coupon1)
        invoice2 = create(:invoice, coupon: coupon2)
        invoice3 = create(:invoice, coupon: coupon2)
        invoice4 = create(:invoice, coupon: coupon1)
        invoice5 = create(:invoice, coupon: coupon1)
        invoice6 = create(:invoice, coupon: coupon1)
  
        create(:transaction, result: 1, invoice: invoice1)
        create(:transaction, result: 1, invoice: invoice2)
        create(:transaction, result: 1, invoice: invoice3)
        create(:transaction, result: 0, invoice: invoice4)
        create(:transaction, result: 1, invoice: invoice5)
        create(:transaction, result: 1, invoice: invoice6)

        expect(coupon1.count_usage).to eq(3)
        expect(coupon2.count_usage).to eq(2)
      end
    end

    describe '#has_pending_invoices?' do
      it 'returns a boolean if the coupon has any invoices that are set to in progress' do
        merchant1 = create(:merchant)
        coupon1 = create(:coupon, merchant: merchant1)
        coupon2 = create(:coupon, merchant: merchant1)
  
        invoice1 = create(:invoice, coupon: coupon1, status: 1)
        invoice2 = create(:invoice, coupon: coupon2, status: 1)
        invoice3 = create(:invoice, coupon: coupon2, status: 1)
        invoice4 = create(:invoice, coupon: coupon1, status: 1)
        invoice5 = create(:invoice, coupon: coupon1, status: 0)
        invoice6 = create(:invoice, coupon: coupon1, status: 1)

        expect(coupon1.has_pending_invoices?).to be true
        expect(coupon2.has_pending_invoices?).to be false
      end
    end

    describe '#formatted_amount' do
      it 'formats the amount based on the coupon type' do
        coupon1 = create(:coupon, coupon_type: 0, amount: 23)
        coupon2 = create(:coupon, coupon_type: 1, amount: 4500)

        expect(coupon1.formatted_amount).to eq('23%')
        expect(coupon2.formatted_amount).to eq('$45.00')
      end
    end
  end

  describe '.class_methods' do
    describe '.enabled_sorted_by_popularity' do
      it 'returns all enabled coupons and sorts them by popularity, the most used to least used. usage is counted as invoices with a successful transaction. it sorts by ID if usage is equal' do
        merchant1 = create(:merchant)

        coupon1 = create(:coupon, merchant: merchant1, status: 1)
        coupon2 = create(:coupon, merchant: merchant1, status: 1)
        coupon3 = create(:coupon, merchant: merchant1, status: 1)
        coupon4 = create(:coupon, merchant: merchant1, status: 0)
        coupon5 = create(:coupon, merchant: merchant1, status: 1)
        coupon6 = create(:coupon, merchant: merchant1, status: 1)
  
        invoice1 = create(:invoice, coupon: coupon1)
        invoice2 = create(:invoice, coupon: coupon1)
        invoice3 = create(:invoice, coupon: coupon1)
        invoice4 = create(:invoice, coupon: coupon1)
        invoice5 = create(:invoice, coupon: coupon2)
        invoice6 = create(:invoice, coupon: coupon2)
        invoice7 = create(:invoice, coupon: coupon3)
        invoice8 = create(:invoice, coupon: coupon4)
        invoice9 = create(:invoice, coupon: coupon4)
        invoice10 = create(:invoice, coupon: coupon4)
        invoice11 = create(:invoice, coupon: coupon4)
        invoice12 = create(:invoice, coupon: coupon4)
        invoice13 = create(:invoice, coupon: coupon5)
        invoice14 = create(:invoice, coupon: coupon5)
        invoice15 = create(:invoice, coupon: coupon5)

        create(:transaction, result: 1, invoice: invoice1)
        create(:transaction, result: 1, invoice: invoice2)
        create(:transaction, result: 1, invoice: invoice3)
        create(:transaction, result: 1, invoice: invoice4)
        create(:transaction, result: 1, invoice: invoice5)
        create(:transaction, result: 1, invoice: invoice6)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 1, invoice: invoice8)
        create(:transaction, result: 1, invoice: invoice9)
        create(:transaction, result: 1, invoice: invoice10)
        create(:transaction, result: 1, invoice: invoice11)
        create(:transaction, result: 1, invoice: invoice12)
        create(:transaction, result: 1, invoice: invoice13)
        create(:transaction, result: 1, invoice: invoice14)
        create(:transaction, result: 1, invoice: invoice15)

        list = Coupon.enabled_sorted_by_popularity

        expect(list).to eq([coupon1, coupon5, coupon2, coupon3, coupon6])
        expect(list).to_not include(coupon4)
      end
    end

    describe '.disabled_sorted_by_popularity' do
      it 'returns all disabled coupons and sorts them by popularity, the most used to least used. usage is counted as invoices with a successful transaction. it sorts by ID if usage is equal' do
        merchant1 = create(:merchant)

        coupon1 = create(:coupon, merchant: merchant1, status: 1)
        coupon2 = create(:coupon, merchant: merchant1, status: 0, name: 'Second Coupon')
        coupon3 = create(:coupon, merchant: merchant1, status: 0, name: 'Third Coupon')
        coupon4 = create(:coupon, merchant: merchant1, status: 1)
        coupon5 = create(:coupon, merchant: merchant1, status: 0, name: 'First Coupon')
        coupon6 = create(:coupon, merchant: merchant1, status: 0, name: 'No Transactions or Invoices')
  
        invoice1 = create(:invoice, coupon: coupon1)
        invoice2 = create(:invoice, coupon: coupon1)
        invoice3 = create(:invoice, coupon: coupon1)
        invoice4 = create(:invoice, coupon: coupon1)
        invoice5 = create(:invoice, coupon: coupon2)
        invoice6 = create(:invoice, coupon: coupon2)
        invoice7 = create(:invoice, coupon: coupon3)
        invoice8 = create(:invoice, coupon: coupon4)
        invoice9 = create(:invoice, coupon: coupon4)
        invoice10 = create(:invoice, coupon: coupon4)
        invoice11 = create(:invoice, coupon: coupon4)
        invoice12 = create(:invoice, coupon: coupon4)
        invoice13 = create(:invoice, coupon: coupon5)
        invoice14 = create(:invoice, coupon: coupon5)
        invoice15 = create(:invoice, coupon: coupon5)

        create(:transaction, result: 1, invoice: invoice1)
        create(:transaction, result: 1, invoice: invoice2)
        create(:transaction, result: 1, invoice: invoice3)
        create(:transaction, result: 1, invoice: invoice4)
        create(:transaction, result: 1, invoice: invoice5)
        create(:transaction, result: 0, invoice: invoice6)
        create(:transaction, result: 0, invoice: invoice6)
        create(:transaction, result: 0, invoice: invoice6)
        create(:transaction, result: 1, invoice: invoice6)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 0, invoice: invoice7)
        create(:transaction, result: 1, invoice: invoice8)
        create(:transaction, result: 1, invoice: invoice9)
        create(:transaction, result: 1, invoice: invoice10)
        create(:transaction, result: 1, invoice: invoice11)
        create(:transaction, result: 1, invoice: invoice12)
        create(:transaction, result: 1, invoice: invoice13)
        create(:transaction, result: 1, invoice: invoice14)
        create(:transaction, result: 1, invoice: invoice15)

        list = Coupon.disabled_sorted_by_popularity

        expect(list).to eq([coupon5, coupon2, coupon3, coupon6])
        expect(list).to_not include(coupon4)
        expect(list).to_not include(coupon1)
      end
    end
  end
end