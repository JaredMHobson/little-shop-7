require "rails_helper"

RSpec.describe "the admin invoices show page" do
  before(:each) do
    @customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
    @customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')
    @customer3 = create(:customer, first_name: 'Spongebob', last_name: 'SquarePants')
    @customer4 = create(:customer, first_name: 'Luffy', last_name: 'Monkey')

    @item1 = create(:item, name: "Cool Item Name")
    @item2 = create(:item)
    @item3 = create(:item)
    @item4 = create(:item)
    @item5 = create(:item)
    @item6 = create(:item)
    @item7 = create(:item)
    @item8 = create(:item)
    @item9 = create(:item)
    @item10 = create(:item)
    @item11 = create(:item)

    @invoice1 = create(:invoice, customer: @customer1, created_at: 'Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00', status: 0)
    @invoice2 = create(:invoice, customer: @customer2, created_at: 'Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00', status: 1)
    @invoice3 = create(:invoice, customer: @customer3, created_at: 'Sun, 17 Mar 2024 00:00:00.800830000 UTC +00:00', status: 2)
    @invoice4 = create(:invoice, customer: @customer4, created_at: 'Sat, 16 Mar 2024 00:00:00.800830000 UTC +00:00', status: 1)
    @invoice5 = create(:invoice, customer: @customer1, created_at: 'Tue, 25 Jun 1997 00:00:00.800830000 UTC +00:00', status: 0)

    create(:invoice_item, item: @item1, invoice: @invoice1, quantity: 10, unit_price: 5000, status: 2)
    create(:invoice_item, item: @item2, invoice: @invoice1, quantity: 3, unit_price: 55000, status: 1)
    create(:invoice_item, item: @item8, invoice: @invoice1, quantity: 8, unit_price: 41000, status: 0)
    create(:invoice_item, item: @item5, invoice: @invoice1, quantity: 4, unit_price: 1000, status: 2)
    create(:invoice_item, item: @item3, invoice: @invoice2, quantity: 5, unit_price: 2000, status: 2)
    create(:invoice_item, item: @item4, invoice: @invoice2, quantity: 5, unit_price: 5050, status: 1)
    create(:invoice_item, item: @item3, invoice: @invoice3, quantity: 1, unit_price: 400000, status: 0)
    create(:invoice_item, item: @item11, invoice: @invoice4, quantity: 1, unit_price: 1000, status: 2)
    create(:invoice_item, item: @item10, invoice: @invoice4, quantity: 5, unit_price: 5000, status: 2)
    create(:invoice_item, item: @item9, invoice: @invoice4, quantity: 3, unit_price: 2000, status: 1)
    create(:invoice_item, item: @item1, invoice: @invoice5, quantity: 6, unit_price: 5100, status: 0)
    create(:invoice_item, item: @item2, invoice: @invoice5, quantity: 8, unit_price: 4500, status: 1)
  end

  describe 'User Story 33' do
    it 'lists all invoice IDs in the system and each ID links to the admin invoice show page' do
      visit admin_invoice_path(@invoice1)

      expect(page).to have_content("Invoice ##{@invoice1.id}")
      expect(page).to have_content("Status: in progress")
      expect(page).to have_content("Created on: Monday, April 15, 1996")
      expect(page).to have_content("Customer: Ron Burgundy")

      expect(page).to_not have_content("Invoice ##{@invoice2.id}")
      expect(page).to_not have_content("Customer: Fred Flintstone")
    end
  end

  describe 'User Story 34' do
    it 'lists all of the items for that invoice including their name, quantity ordered, price sold for and status' do
      visit admin_invoice_path(@invoice1)

      within '#admin_invoice_items' do
        expect(page).to have_content("Cool Item Name")
        expect(page).to have_content("10")
        expect(page).to have_content("$50.00")
        expect(page).to have_content("Shipped")

        @invoice1.invoice_items.each do |invoice_item|
          within "#invoice_item_#{invoice_item.id}_info" do
            expect(page).to have_content("#{invoice_item.item.name}")
            expect(page).to have_content(" #{invoice_item.quantity}")
            expect(page).to have_content("#{invoice_item.status.capitalize}")
          end
        end
      end
    end
  end

  describe 'User Story 35' do
    it 'shows the total revenue that will be generated from this invoice' do
      visit admin_invoice_path(@invoice1)

      expect(page).to have_content('Total Revenue: $5,470.00')

      visit admin_invoice_path(@invoice2)

      expect(page).to have_content('Total Revenue: $352.50')
    end
  end

  describe 'User Story 36' do
    it 'has a select field and the current status is selected and i can select a different status and click Update Invoice Status to update its status and Im redirected back to the show page' do
      visit admin_invoice_path(@invoice1)

      expect(page).to have_field(:status, with: 'in progress')

      select('completed', from: :status)
      click_button('Update Invoice Status')

      expect(current_path).to eq(admin_invoice_path(@invoice1))
      expect(page).to have_field(:status, with: 'completed')
    end
  end

  describe 'User Story 8 Solo' do
    it 'has the name and code of the coupon that was used if there was one, and the total revenue and net revenue for that invoice shows' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)

      coupon1 = create(:coupon, coupon_type: 1, amount: 58000, merchant: merchant1)

      item1 = create(:item, merchant: merchant1)
      item2 = create(:item, merchant: merchant1)
      item3 = create(:item, merchant: merchant1)
      item4 = create(:item, merchant: merchant1)
      item5 = create(:item, merchant: merchant2)

      invoice1 = create(:invoice, coupon: coupon1)

      create(:invoice_item, invoice: invoice1, item: item1, quantity: 5, unit_price: 5000) #25000
      create(:invoice_item, invoice: invoice1, item: item2, quantity: 10, unit_price: 2000) #20000
      create(:invoice_item, invoice: invoice1, item: item3, quantity: 3, unit_price: 4000) #12000
      create(:invoice_item, invoice: invoice1, item: item4, quantity: 7, unit_price: 7000) #49000
      create(:invoice_item, invoice: invoice1, item: item5, quantity: 1, unit_price: 2000) #2000

      visit admin_invoice_path(invoice1)

      expect(page).to have_content("Coupon Name: #{coupon1.name}")
      expect(page).to have_content("Coupon Code: #{coupon1.code}")
      expect(page).to have_content("Amount: $580.00 Off")
      expect(page).to have_content('Total Revenue: $1,080.00')
      expect(page).to have_content('Net Revenue: $500.00')

      coupon1.update(coupon_type: 0, amount: 40)

      visit admin_invoice_path(invoice1)

      expect(page).to have_content("Coupon Name: #{coupon1.name}")
      expect(page).to have_content("Coupon Code: #{coupon1.code}")
      expect(page).to have_content("Amount: 40% Off")
      expect(page).to have_content('Total Revenue: $1,080.00')
      expect(page).to have_content('Net Revenue: $656.00')

      invoice1.update(coupon: nil)

      visit admin_invoice_path(invoice1)

      expect(page).to have_content('No Coupon Found')
      expect(page).to have_content('Total Revenue: $1,080.00')
      expect(page).to have_content('Net Revenue: $1,080.00')
    end
  end
end