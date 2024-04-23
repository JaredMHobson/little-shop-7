require 'rails_helper'

RSpec.describe 'Merchant Invoices Show' do
  before(:each) do
    @customer1 = create(:customer, first_name: 'Ron', last_name: 'Burgundy')
    @customer2 = create(:customer, first_name: 'Fred', last_name: 'Flintstone')
    @customer3 = create(:customer, first_name: 'Spongebob', last_name: 'SquarePants')
    @customer4 = create(:customer, first_name: 'Luffy', last_name: 'Monkey')

    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    @merchant3 = create(:merchant)
    @merchant4 = create(:merchant)

    @item1 = create(:item, name: "Cool Item Name", merchant: @merchant1)
    @item2 = create(:item, merchant: @merchant1)
    @item3 = create(:item, merchant: @merchant1)
    @item4 = create(:item, merchant: @merchant1)
    @item5 = create(:item, merchant: @merchant2)
    @item6 = create(:item, merchant: @merchant2)
    @item7 = create(:item, merchant: @merchant3)
    @item8 = create(:item, merchant: @merchant3)
    @item9 = create(:item, merchant: @merchant3)
    @item10 = create(:item, merchant: @merchant4)
    @item11 = create(:item, merchant: @merchant4)

    @invoice1 = create(:invoice, customer: @customer1, created_at: 'Mon, 15 Apr 1996 00:00:00.800830000 UTC +00:00', status: 0)
    @invoice2 = create(:invoice, customer: @customer2, created_at: 'Sun, 01 Jan 2023 00:00:00.800830000 UTC +00:00', status: 1)
    @invoice3 = create(:invoice, customer: @customer3, created_at: 'Sun, 17 Mar 2024 00:00:00.800830000 UTC +00:00', status: 2)
    @invoice4 = create(:invoice, customer: @customer4, created_at: 'Sat, 16 Mar 2024 00:00:00.800830000 UTC +00:00', status: 1)
    @invoice5 = create(:invoice, customer: @customer1, created_at: 'Tue, 25 Jun 1997 00:00:00.800830000 UTC +00:00', status: 0)

    @invoice_item1 = create(:invoice_item, item: @item1, invoice: @invoice1, quantity: 10, unit_price: 5000, status: 2)
    @invoice_item2 = create(:invoice_item, item: @item2, invoice: @invoice1, quantity: 3, unit_price: 55000, status: 1)
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

  describe 'User Story 15' do
    it 'shows information related to that invoice including invoice id, invoice status, invoice created at date and the customers name' do
      visit merchant_invoice_path(@merchant1, @invoice1)

      expect(page).to have_content("Invoice ##{@invoice1.id}")

      within '#merchant_invoice_info' do
        expect(page).to have_content("Status: in progress")
        expect(page).to have_content("Created on: Monday, April 15, 1996")
        expect(page).to have_content("Customer: Ron Burgundy")
      end
    end
  end

  describe 'User Story 16' do
    it 'lists all of my items on the invoice including their name, quantity ordered, price sold for and status and does not show items from other merchants' do
      visit merchant_invoice_path(@merchant1, @invoice1)

      within '#merchant_invoice_items' do
        @invoice1.invoice_items.each do |invoice_item|
          if invoice_item.merchant == @merchant1
            expect(page).to have_content("#{invoice_item.item.name}")
            expect(page).to have_content("#{invoice_item.quantity}")
            expect(page).to have_content(invoice_item.status)
          end
        end

        expect(page).to have_content("Cool Item Name")
        expect(page).to have_content("10")
        expect(page).to have_content("$50.00")
        expect(page).to have_content("shipped")
      end
    end
  end

  describe 'User Story 17' do
    it 'shows the total revenue that will be generated from all of my items on the invoice' do
      visit merchant_invoice_path(@merchant1, @invoice1)

      within '#merchant_invoice_info' do
        expect(page).to have_content("Total Revenue: $2,150.00")
      end

      visit merchant_invoice_path(@merchant1, @invoice2)

      within '#merchant_invoice_info' do
        expect(page).to have_content("Total Revenue: $352.50")
      end
    end
  end

  describe 'User Story 18' do
    it 'has a select field next to each item and the current status is selected and i can select a different status and click Update Invoice Status to update its status and Im redirected back to the show page' do
      visit merchant_invoice_path(@merchant1, @invoice1)

      within '#merchant_invoice_items' do
        @invoice1.invoice_items.each do |invoice_item|
          if invoice_item.merchant == @merchant1
            within "#merchant_invoice_item_#{invoice_item.id}" do
              expect(page).to have_field(:status, with: invoice_item.status)

              select('shipped', from: :status)
              click_button('Update Item Status')

              expect(current_path).to eq(merchant_invoice_path(@merchant1, @invoice1))
              expect(page).to have_field(:status, with: 'shipped')
            end
          end
        end
      end
    end
  end

  describe 'User Story 7 Solo' do
    it 'shows the net revenue that will be generated from all of my items on the invoice after applying any coupon and I see the name, as a link to that coupons show page, and code of the coupon' do
      coupon1 = create(:coupon, coupon_type: 0, amount: 20, merchant: @merchant1)
      @invoice1.update(coupon: coupon1)

      visit merchant_invoice_path(@merchant1, @invoice1)

      within '#merchant_invoice_info' do
        expect(page).to have_content("Total Revenue: $2,150.00")
        expect(page).to have_content("Net Revenue: $1,720.00")
      end

      expect(page).to have_link("#{coupon1.name}", href: merchant_coupon_path(@merchant1, coupon1))

      coupon2 = create(:coupon, coupon_type: 1, amount: 30000, merchant: @merchant1)
      @invoice2.update(coupon: coupon2)

      visit merchant_invoice_path(@merchant1, @invoice2)

      within '#merchant_invoice_info' do
        expect(page).to have_content("Total Revenue: $352.50")
        expect(page).to have_content("Net Revenue: $52.50")
      end

      expect(page).to have_link("#{coupon2.name}", href: merchant_coupon_path(@merchant1, coupon2))
    end
  end
end