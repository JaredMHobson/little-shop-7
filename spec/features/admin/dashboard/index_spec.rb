require 'rails_helper'

RSpec.describe "Admin Dashboard Page", type: :feature do
  before :each do
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

    visit admin_dashboard_index_path
  end

  describe "User Story 19" do
    it "displays that this is the admin dashboard" do
      expect(page).to have_content("Admin Dashboard")
    end
  end

  describe "User Story 20" do
    it "displays links to merchants index and invoice index" do
      expect(page).to have_link("Merchants", href: admin_merchants_path)
      expect(page).to have_link("Invoices", href: admin_invoices_path)
    end
  end

  describe "User Story 21" do
    it "displays top five customers" do
      expect(page).to have_content("#{@customer3.first_name}")
      expect(page).to have_content("#{@customer1.first_name}")
      expect(page).to have_content("#{@customer6.first_name}")
      expect(page).to have_content("#{@customer4.first_name}")
      expect(page).to have_content("#{@customer2.first_name}")

      expect("#{@customer3.first_name}").to appear_before("#{@customer1.first_name}")
    end

    it "displays top five customers' transaction count" do
      expect(page).to have_content("purchases", count: 5)
    end
  end

  describe "User Story 22" do
    it "displays the invoice IDs of incomplete invoices" do
      expect(page).to have_content(@invoice_customer7.id)
    end

    it "has a link to the invoice show page from the invoice ID" do
      expect(page).to have_link("Invoice ##{@invoice_customer7.id}")
    end
  end

  describe "User Story 23" do
    it "displays the order of incomplete invoices from oldest to newest" do
      expect("#{@invoice_customer5.id}").to appear_before("#{@invoice_customer7.id}")
    end
  end
end
