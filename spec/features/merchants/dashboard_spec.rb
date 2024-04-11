require 'rails_helper'

RSpec.describe 'merchant dashboard show page', type: :feature do
  before(:each) do
        @merchant1 = create(:merchant)

        @wood = create(:item, name: "Organic wood", merchant_id: @merchant1.id)
        @mat = create(:item, name: "Yoga mat", merchant_id: @merchant1.id)
        @headphones = create(:item, name: "Headphones", merchant_id: @merchant1.id)
        # @item_4 = create(:item, name: "Kangen water", merchant_id: @merchant1.id)
        # @item_5 = create(:item, name: "Left shoe", merchant_id: @merchant1.id)
        # @item_6 = create(:item, name: "Right shoe", merchant_id: @merchant1.id)
        # @item_7 = create(:item, name: "Coffee mug", merchant_id: @merchant1.id)
        # @item_8 = create(:item, name: "Bed frame", merchant_id: @merchant1.id)
        # @item_9 = create(:item, name: "Tiny house", merchant_id: @merchant1.id)
        # @item_10 = create(:item, name: "Cat litter", merchant_id: @merchant1.id)

        # @customer_list = create_list(:customer, 8)

        #has a first_name and last_name.  Can interpolate in testing
        @customer_1 = create(:customer) #Will have the least amount of transactions @1
        @customer_2 = create(:customer) #most amount of transactions 
        @customer_3 = create(:customer)
        @customer_4 = create(:customer) #has an invoice-item packaged
        @customer_5 = create(:customer) #has an invoice_item pending
        @customer_6 = create(:customer) #has a failed transaction

        # invoices_for_customer_1 = create_list(:invoice, 8 customer: @customer_1)

        # @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 1)
        # @invoice_1 = @customer_1.invoices.create( status: 1)
                                                                              # do I need to change status here?
        @invoice_1 = create(:invoice, customer_id: @customer_1.id, status: 1) #status = ['in progress', 'completed', 'cancelled']
        @invoice_2 = create(:invoice, customer_id: @customer_2.id, status: 1)
        @invoice_3 = create(:invoice, customer_id: @customer_3.id, status: 1)
        @invoice_4 = create(:invoice, customer_id: @customer_4.id, status: 1)
        @invoice_5 = create(:invoice, customer_id: @customer_5.id, status: 1)
        @invoice_6 = create(:invoice, customer_id: @customer_6.id, status: 1)

        # @invoice_7 = create(:invoice, customer_id: @customer_2.id, status: 1)
        # @invoice_8 = create(:invoice, customer_id: @customer_3.id, status: 1)


        # question on unit price.  Is it per price of item or price of whole invoice (item * quantity)
        @invoice_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: 23, status: 2) #status= [:pending, :packaged, :shipped]
        @invoice_item_2 = InvoiceItem.create!(item_id: @wood.id, invoice_id: @invoice_2.id, quantity: 6, unit_price: 35, status: 2)
        @invoice_item_3 = InvoiceItem.create!(item_id: @mat.id, invoice_id: @invoice_3.id, quantity: 5, unit_price: 20, status: 2)
        @invoice_item_4 = InvoiceItem.create!(item_id: @headphones.id, invoice_id: @invoice_4.id, quantity: 4, unit_price: 100, status: 1)
        @invoice_item_5 = InvoiceItem.create!(item_id: @wood.id, invoice_id: @invoice_5.id, quantity: 3, unit_price: 35, status: 0)
        @invoice_item_6 = InvoiceItem.create!(item_id: @mat.id, invoice_id: @invoice_6.id, quantity: 6, unit_price: 20, status: 2)


        @transactions1 = create(:transaction, invoice_id: 1, result: 1) #result 0 = failed.  1 = success
        @transactions2 = create(:transaction, invoice_id: 2, result: 1)
        @transactions3 = create(:transaction, invoice_id: 3, result: 1)
        @transactions4 = create(:transaction, invoice_id: 4, result: 1)
        @transactions5 = create(:transaction, invoice_id: 5, result: 1)
        @transactions6 = create(:transaction, invoice_id: 6, result: 0) #This is the only failed transaction and is on customer # 6
        visit dashboard_merchant_path(@merchant1)

  end

  describe ' USER STORY #1' do
    describe ' as a user when I visit /merchants/:merchant_id/dashboard' do
      
      it 'displays' do
        # Then I see the name of my merchant
        expect(page).to have_content(@merchant1.name)
      end
    end 
  end

  describe 'User Story 2' do
    it 'has links for merchant items index and invoices index' do
      # As a merchant,
      # When I visit my merchant dashboard (/merchants/:merchant_id/dashboard)
      # Then I see link to my merchant items index (/merchants/:merchant_id/items)
      expect(page).to have_link("Merchant Items")
      # And I see a link to my merchant invoices index (/merchants/:merchant_id/invoices)
      expect(page).to have_link("Merchant Invoices")
    end
  end

  describe 'User Story 3' do
    it 'shows the names of the top 5 customers with the largest number of successful transactions' do
      # As a merchant,
      # When I visit my merchant dashboard (/merchants/:merchant_id/dashboard)
      # Then I see the names of the top 5 customers
      # who have conducted the largest number of successful transactions with my merchant
      # And next to each customer name I see the number of successful transactions they have
      # conducted with my merchant
      within '.top5' do
        expect(page).to have_content("Customer name: #{@customer1.name} - #{@customer1.successful_transations} successful transactions" )
        expect(page).to have_content()
        expect(page).to have_content()
        expect(page).to have_content()
        expect(page).to have_content()
      end
    end
  end
end