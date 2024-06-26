require "rails_helper"

RSpec.describe Invoice, type: :model do
  before :each do
    @invoice = create(:invoice)
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
   
    @items_merchant1 = create_list(:item, 5, merchant: @merchant1)
    @items_merchant2 = create_list(:item, 5, merchant: @merchant2)
   
    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @customer3 = create(:customer)
    @customer4 = create(:customer)
    @customer5 = create(:customer)
    @customer6 = create(:customer)
    @customer7 = create(:customer)

    @invoice_customer1 = create(:invoice, customer: @customer1, status: 1)
    @invoice_customer2 = create(:invoice, customer: @customer2, status: 1)
    @invoice_customer3 = create(:invoice, customer: @customer3, status: 1)
    @invoice_customer4 = create(:invoice, customer: @customer4, status: 1)
    @invoice_customer5 = create(:invoice, customer: @customer5, status: 1)
    @invoice_customer6 = create(:invoice, customer: @customer6, status: 2)
    @invoice_customer7 = create(:invoice, customer: @customer7, status: 2)

    @invoice_items1 = create(:invoice_item, invoice: @invoice_customer1, item: @items_merchant1.first, status: 2 )
    @invoice_items2 = create(:invoice_item, invoice: @invoice_customer2, item: @items_merchant1.first, status: 2 )
    @invoice_items3 = create(:invoice_item, invoice: @invoice_customer3, item: @items_merchant1.second, status: 2 )
    @invoice_items4 = create(:invoice_item, invoice: @invoice_customer4, item: @items_merchant1.third, status: 2 )
    @invoice_items5 = create(:invoice_item, invoice: @invoice_customer5, item: @items_merchant1.third, status: 2 )
    @invoice_items6 = create(:invoice_item, invoice: @invoice_customer6, item: @items_merchant1.fifth, status: 2 )
    @invoice_items7 = create(:invoice_item, invoice: @invoice_customer7, item: @items_merchant1.fifth, status: 1 )
    @invoice_items8 = create(:invoice_item, invoice: @invoice_customer1, item: @items_merchant2.first, status: 2 )
    @invoice_items9 = create(:invoice_item, invoice: @invoice_customer2, item: @items_merchant2.first, status: 2 )
    @invoice_items10 = create(:invoice_item, invoice: @invoice_customer3, item: @items_merchant2.second, status: 2 )
    @invoice_items11 = create(:invoice_item, invoice: @invoice_customer4, item: @items_merchant2.third, status: 2 )
    @invoice_items12 = create(:invoice_item, invoice: @invoice_customer5, item: @items_merchant2.third, status: 0 )
    @invoice_items13 = create(:invoice_item, invoice: @invoice_customer6, item: @items_merchant2.fifth, status: 0 )
    @invoice_items14 = create(:invoice_item, invoice: @invoice_customer7, item: @items_merchant2.fifth, status: 1 )

    @transactions_invoice1 = create_list(:transaction, 5, invoice: @invoice_customer1, result: 1)
    @transactions_invoice2 = create_list(:transaction, 4, invoice: @invoice_customer2, result: 0)
    @transactions_invoice3 = create_list(:transaction, 6, invoice: @invoice_customer3, result: 1)
    @transactions_invoice4 = create_list(:transaction, 7, invoice: @invoice_customer4, result: 1)
    @transactions_invoice5 = create_list(:transaction, 3, invoice: @invoice_customer5, result: 0)
    @transactions_invoice6 = create_list(:transaction, 9, invoice: @invoice_customer6, result: 1)
    @transactions_invoice7 = create_list(:transaction, 10, invoice: @invoice_customer7, result: 0)
    @transactions_invoice8 = create_list(:transaction, 5, invoice: @invoice_customer1, result: 1)
    @transactions_invoice9 = create_list(:transaction, 4, invoice: @invoice_customer2, result: 1)
    @transactions_invoice10 = create_list(:transaction, 6, invoice: @invoice_customer3, result: 1)
    @transactions_invoice11 = create_list(:transaction, 7, invoice: @invoice_customer4, result: 0)
    @transactions_invoice12 = create_list(:transaction, 3, invoice: @invoice_customer5, result: 0)
    @transactions_invoice13 = create_list(:transaction, 9, invoice: @invoice_customer6, result: 0)
    @transactions_invoice14 = create_list(:transaction, 10, invoice: @invoice_customer7, result: 0)
  end

  describe "relationships" do
    it { should belong_to(:customer) }
    it { should belong_to(:coupon).optional }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values({ 'in progress' => 0, 'completed' => 1, 'cancelled' => 2 }) }
  end

  describe "class methods" do
    it ".query for incomplete invoices ordered by oldest to newest" do
      list_test = Invoice.all.incomplete_invoices.limit(3)
      expect(list_test).to match_array([@invoice_customer7, @invoice_customer6, @invoice_customer5])
    end
  end

  describe "instance method" do
    it "#formatted_date" do
      @customer = Customer.create!(first_name: "Blake", last_name: "Sergesketter")
      @invoice = Invoice.create!(status: 1, customer_id: @customer.id, created_at: "Sat, 13 Apr 2024 23:10:10.717784000 UTC +00:00")
      expect(@invoice.formatted_date).to eq("Saturday, April 13, 2024")
      #Saturday, April 13, 2024
    end

    it 'customer_name' do
      customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
      invoice1 = create(:invoice, customer: customer1)
      customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')
      invoice2 = create(:invoice, customer: customer2)
  
      expect(invoice1.customer_name).to eq('Ron Burgundy')
      expect(invoice2.customer_name).to eq('Fred Flintstone')
    end

    it 'total_revenue' do
      customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
      customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')

      item1 = create(:item, name: "Cool Item Name")
      item2 = create(:item)

      invoice1 = create(:invoice, customer: customer1, created_at: 'Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00', status: 0)
      invoice2 = create(:invoice, customer: customer2, created_at: 'Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00', status: 1)

      create(:invoice_item, item: item1, invoice: invoice1, quantity: 10, unit_price: 5000, status: 2) 
      create(:invoice_item, item: item2, invoice: invoice1, quantity: 3, unit_price: 55000, status: 1) 
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 8, unit_price: 41000, status: 0) 
      create(:invoice_item, item: item2, invoice: invoice1, quantity: 4, unit_price: 1000, status: 2) 

      create(:invoice_item, item: item1, invoice: invoice2, quantity: 5, unit_price: 2000, status: 2)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 5, unit_price: 5050, status: 1)

      expect(invoice1.total_revenue).to eq(547000)
      expect(invoice2.total_revenue).to eq(35250)
    end

    it 'total_revenue_for_merchant' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)

      item1 = create(:item, merchant: merchant1)
      item2 = create(:item, merchant: merchant1)
      item3 = create(:item, merchant: merchant2)
      item4 = create(:item, merchant: merchant2)

      invoice1 = create(:invoice)
      invoice2 = create(:invoice)

      create(:invoice_item, invoice: invoice1, item: item1, quantity: 10, unit_price: 400)
      create(:invoice_item, invoice: invoice1, item: item2, quantity: 5, unit_price: 12000)
      create(:invoice_item, invoice: invoice1, item: item3, quantity: 8, unit_price: 5000)
      create(:invoice_item, invoice: invoice1, item: item4, quantity: 1, unit_price: 4000)
      create(:invoice_item, invoice: invoice2, item: item1, quantity: 11, unit_price: 650)
      create(:invoice_item, invoice: invoice2, item: item3, quantity: 7, unit_price: 8000)
      create(:invoice_item, invoice: invoice2, item: item4, quantity: 5, unit_price: 90000)

      expect(invoice1.total_revenue_for_merchant(merchant1)).to eq(64000)
      expect(invoice2.total_revenue_for_merchant(merchant1)).to eq(7150)
    end

    describe '#net_revenue_for_merchant' do
      it 'returns the net revenue of an invoice for only a specific merchants items by taking a percent off their items prices if the coupon is a percent type and just shows the total revenue if there is no coupon' do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)

        coupon1 = create(:coupon, coupon_type: 0, amount: 20, merchant: merchant1)

        item1 = create(:item, merchant: merchant1)
        item2 = create(:item, merchant: merchant1)
        item3 = create(:item, merchant: merchant1)
        item4 = create(:item, merchant: merchant2)

        invoice1 = create(:invoice, coupon: coupon1)

        create(:invoice_item, invoice: invoice1, item: item1, quantity: 5, unit_price: 5000) #25000
        create(:invoice_item, invoice: invoice1, item: item2, quantity: 10, unit_price: 2000) #20000
        create(:invoice_item, invoice: invoice1, item: item3, quantity: 3, unit_price: 4000) #12000
        create(:invoice_item, invoice: invoice1, item: item4, quantity: 6, unit_price: 12000) #72000

        expect(invoice1.net_revenue_for_merchant(merchant1)).to eq(45600.0)
        expect(invoice1.net_revenue_for_merchant(merchant2)).to eq(72000)
      end

      it 'returns the net revenue of an invoice for only a specific merchants items by taking a flat dollar amount off their items prices if the coupon is a dollar type and returns 0 if the revenue is less than 0' do
        merchant1 = create(:merchant)

        coupon1 = create(:coupon, coupon_type: 1, amount: 5000, merchant: merchant1)

        item1 = create(:item, merchant: merchant1)
        item2 = create(:item, merchant: merchant1)
        item3 = create(:item, merchant: merchant1)

        invoice1 = create(:invoice, coupon: coupon1)

        create(:invoice_item, invoice: invoice1, item: item1, quantity: 5, unit_price: 5000) #25000
        create(:invoice_item, invoice: invoice1, item: item2, quantity: 10, unit_price: 2000) #20000
        create(:invoice_item, invoice: invoice1, item: item3, quantity: 3, unit_price: 4000) #12000

        coupon2 = create(:coupon, coupon_type: 1, amount: 50000, merchant: merchant1)
        item4 = create(:item, merchant: merchant1)
        invoice2 = create(:invoice, coupon: coupon2)
        create(:invoice_item, invoice: invoice2, item: item4, quantity: 7, unit_price: 7000) #49000

        expect(invoice1.net_revenue_for_merchant(merchant1)).to eq(52000)
        expect(invoice2.net_revenue_for_merchant(merchant1)).to eq(0)
      end
    end

    describe '#net_revenue' do
      it 'with a percent coupon, it returns the entire net revenue of an invoice by first subtracting the amount saved on only the coupons merchants items. it returns the total revenue if there is no coupon' do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)

        coupon1 = create(:coupon, coupon_type: 0, amount: 50, merchant: merchant1)

        item1 = create(:item, merchant: merchant1)
        item2 = create(:item, merchant: merchant1)
        item3 = create(:item, merchant: merchant1)
        item4 = create(:item, merchant: merchant2)

        invoice1 = create(:invoice, coupon: coupon1)

        create(:invoice_item, invoice: invoice1, item: item1, quantity: 5, unit_price: 5000) #25000
        create(:invoice_item, invoice: invoice1, item: item2, quantity: 10, unit_price: 2000) #20000
        create(:invoice_item, invoice: invoice1, item: item3, quantity: 3, unit_price: 4000) #12000
        create(:invoice_item, invoice: invoice1, item: item4, quantity: 6, unit_price: 12000) #72000

        expect(invoice1.net_revenue).to eq(100500.0)

        invoice1.update(coupon: nil)

        expect(invoice1.net_revenue).to eq(129000)
      end

      it 'with a dollar coupon, it returns the entire net revenue of an invoice by subtracting the coupon amount from the total revenue. it returns 0 if this results in less than 0' do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)

        coupon1 = create(:coupon, coupon_type: 1, amount: 58000, merchant: merchant1)

        item1 = create(:item, merchant: merchant1)
        item2 = create(:item, merchant: merchant1)
        item3 = create(:item, merchant: merchant1)
        item5 = create(:item, merchant: merchant2)

        invoice1 = create(:invoice, coupon: coupon1)

        create(:invoice_item, invoice: invoice1, item: item1, quantity: 5, unit_price: 5000) #25000
        create(:invoice_item, invoice: invoice1, item: item2, quantity: 10, unit_price: 2000) #20000
        create(:invoice_item, invoice: invoice1, item: item3, quantity: 3, unit_price: 4000) #12000
        create(:invoice_item, invoice: invoice1, item: item5, quantity: 1, unit_price: 2000) #12000

        coupon2 = create(:coupon, coupon_type: 1, amount: 50000, merchant: merchant1)
        item4 = create(:item, merchant: merchant1)
        invoice2 = create(:invoice, coupon: coupon2)
        create(:invoice_item, invoice: invoice2, item: item4, quantity: 7, unit_price: 7000) #49000

        expect(invoice1.net_revenue).to eq(1000)
        expect(invoice2.net_revenue).to eq(0)
      end
    end

    describe '#coupon_savings' do
      it 'returns the amount saved on a coupon, for a dollar type, this is just the coupon amount. it returns 0 if there is no coupon' do
        merchant1 = create(:merchant)

        coupon1 = create(:coupon, coupon_type: 0, amount: 25, merchant: merchant1)

        item1 = create(:item, merchant: merchant1)
        item2 = create(:item, merchant: merchant1)
        item3 = create(:item, merchant: merchant1)

        invoice1 = create(:invoice, coupon: coupon1)

        create(:invoice_item, invoice: invoice1, item: item1, quantity: 5, unit_price: 5000) #25000
        create(:invoice_item, invoice: invoice1, item: item2, quantity: 10, unit_price: 2000) #20000
        create(:invoice_item, invoice: invoice1, item: item3, quantity: 3, unit_price: 4000) #12000

        expect(invoice1.coupon_savings).to eq(14250.0)

        coupon1.update(coupon_type: 1)

        expect(invoice1.coupon_savings).to eq(25)

        invoice1.update(coupon: nil)

        expect(invoice1.coupon_savings).to eq(0)
      end
    end
  end
end
