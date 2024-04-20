require 'rails_helper'

RSpec.describe 'merchant dashboard show page', type: :feature do
  before(:each) do
    @merchant1 = create(:merchant)
    # @merchant2 = create(:merchant)

    @table = create(:item, name: "table", merchant: @merchant1)
    @pen = create(:item, name: "pen", merchant: @merchant1)
    @mat = create(:item, name: "yoga mat", merchant: @merchant1)
    @mug = create(:item, name: "mug", merchant: @merchant1)
    @ember = create(:item, name: "ember", merchant: @merchant1)
    @plant = create(:item, name: "plant", merchant: @merchant1)
    # @items_merchant2 = create_list(:item, 5, merchant: @merchant2)

    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @customer3 = create(:customer)
    @customer4 = create(:customer)
    @customer5 = create(:customer)
    @customer6 = create(:customer)

    @invoices_customer1 = create(:invoice, customer: @customer1, status: 1)
    @invoices_customer2 = create(:invoice, customer: @customer2, status: 1)
    @invoices_customer3 = create(:invoice, customer: @customer3, status: 1)
    @invoices_customer4 = create(:invoice, customer: @customer4, status: 1)
    @invoices_customer5 = create(:invoice, customer: @customer5, status: 1)
    @invoices_customer6 = create(:invoice, customer: @customer6, status: 1)

    @invoice_items1 = create(:invoice_item, invoice: @invoices_customer1, item: @table, status: 0 ) #pending
    @invoice_items2 = create(:invoice_item, invoice: @invoices_customer2, item: @pen, status: 0 ) #pending
    @invoice_items3 = create(:invoice_item, invoice: @invoices_customer3, item: @mat, status: 1 ) #packaged
    @invoice_items4 = create(:invoice_item, invoice: @invoices_customer4, item: @mug, status: 1 ) #packaged
    @invoice_items5 = create(:invoice_item, invoice: @invoices_customer5, item: @ember, status: 2 )#shiped
    @invoice_items6 = create(:invoice_item, invoice: @invoices_customer6, item: @plant, status: 2 )#shipped
    
    @transactions_invoice1 = create_list(:transaction, 5, invoice: @invoices_customer1, result: 1)
    @transactions_invoice2 = create_list(:transaction, 4, invoice: @invoices_customer2, result: 1)
    @transactions_invoice3 = create_list(:transaction, 6, invoice: @invoices_customer3, result: 1)
    @transactions_invoice4 = create_list(:transaction, 7, invoice: @invoices_customer4, result: 1)
    @transactions_invoice5 = create_list(:transaction, 3, invoice: @invoices_customer5, result: 1)
    @transactions_invoice6 = create_list(:transaction, 9, invoice: @invoices_customer6, result: 1)

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
      expect(page).to have_link("My Items", href: merchant_items_path(@merchant1))
      expect(page).to have_link("My Invoices", href: merchant_invoices_path(@merchant1))
    end
  end

  describe 'User Story 3' do
    it 'shows the names of the top 5 customers with the largest number of successful transactions' do
      within '.top5' do
        @merchant1.top_five_customers.each do |customer|
          expect(page).to have_content("Customer name: #{customer.first_name} #{customer.last_name} - #{customer.transaction_count} successful transactions")
        end
      end
    end
  end

  describe "User Story 4" do # Would like to refactor this hardcoded so nested within blocks isn't so visually taxing"
    it "has a link next to each packaged invoice item titled as ID from the invoice item is on" do
      expect(page).to have_content("Items Ready to Ship")
      within "#packaged_items-#{@merchant1.id}" do
        @merchant1.packaged_items.each do |packaged_item|
          expect(page).to have_content(packaged_item.name)
          expect(page).to have_link(packaged_item.invoice_id.to_s, href: merchant_invoice_path(@merchant1, packaged_item.invoice_id)) 
        end
      end
    end
  end

  describe "US 5" do
    it "displays created_at date ordered by oldest first" do
      within "#packaged_items-#{@merchant1.id}" do
        @merchant1.packaged_items.each do |packaged_item|
          expect(@merchant1.formatted_date(packaged_item.created_at)).to match(/\A[A-Z][a-z]+, [A-Z][a-z]+ \d{1,2}, \d{4}\z/)
          expect("yoga mat").to appear_before("mug")
        end
      end
    end
  end

  describe 'User Story 1 Solo' do
    it 'has a link to my coupons index page' do
      expect(page).to have_link("My Coupons", href: merchant_coupons_path(@merchant1))

      click_link("My Coupons")

      expect(current_path).to eq(merchant_coupons_path(@merchant1))
    end
  end
end