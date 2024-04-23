require "rails_helper"

RSpec.describe "the admin merchants index page" do
  before(:each) do
    @merchant_list = create_list(:merchant, 3)
  end

  describe 'User Story 24' do
    it 'lists the name of each merchant' do
      visit admin_merchants_path

      within '#admin_merchants_list' do
        @merchant_list.each do |merchant|
          expect(page).to have_content(merchant.name)
        end
      end
    end
  end

  describe 'User Story 25' do
    it 'links to each merchants show page' do
      visit admin_merchants_path

      within '#admin_merchants_list' do
        @merchant_list.each do |merchant|
          expect(page).to have_link(merchant.name, href: admin_merchant_path(merchant))
        end
      end
    end
  end

  describe 'User Story 27' do
    it 'has an enable and disable button next to each merchant and when I click one of these I am redirected to the index page and see that merchants status has changed' do
      merchant_disabled = create(:merchant, status: 0)
      merchant_enabled = create(:merchant, status: 1)
      visit admin_merchants_path

      within '#admin_merchants_list' do
        Merchant.all.each do |merchant|
          within "#admin_merchant_#{merchant.id}" do
            if merchant.enabled?
              expect(page).to have_button('Disable')
              expect(page).to_not have_button('Enable')

              click_button('Disable')

              expect(current_path).to eq(admin_merchants_path)

              expect(page).to have_button('Enable')
              expect(page).to_not have_button('Disable')
            else
              expect(page).to have_button('Enable')
              expect(page).to_not have_button('Disable')

              click_button('Enable')

              expect(current_path).to eq(admin_merchants_path)

              expect(page).to have_button('Disable')
              expect(page).to_not have_button('Enable')
            end
          end
        end
      end
    end
  end

  describe 'User Story 28' do
    it 'only shows enabled merchants in the enabled merchants section and disabled merchants in the disabled merchants section' do
      enabled_merchant = create(:merchant, status: 1)
      disabled_merchant = create(:merchant, status: 0)
      visit admin_merchants_path

      within '#enabled_merchants' do
        expect(page).to have_content(enabled_merchant.name)
        expect(page).to_not have_content(disabled_merchant.name)

        @merchant_list.each do |merchant|
          expect(page).to have_content(merchant.name) if merchant.enabled?
        end
      end

      within '#disabled_merchants' do
        expect(page).to have_content(disabled_merchant.name)
        expect(page).to_not have_content(enabled_merchant.name)

        @merchant_list.each do |merchant|
          expect(page).to have_content(merchant.name) if merchant.disabled?
        end
      end
    end
  end

  describe 'User Story 29' do
    it 'has a link to create a new merchant' do
      visit admin_merchants_path

      expect(page).to have_link('New Merchant', href: new_admin_merchant_path)

      click_link('New Merchant')

      expect(current_path).to eq(new_admin_merchant_path)
    end
  end

  describe 'Top Merchants' do
    before(:each) do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @merchant3 = create(:merchant)
      @merchant4 = create(:merchant)
      @merchant5 = create(:merchant)
      @merchant6 = create(:merchant)
      @merchant7 = create(:merchant)

      @invoice1 = create(:invoice)
      @invoice2 = create(:invoice)
      @invoice3 = create(:invoice)
      @invoice4 = create(:invoice)
      @invoice5 = create(:invoice)
      @invoice6 = create(:invoice)
      @invoice7 = create(:invoice)

      @item1 = create(:item, merchant: @merchant1)
      @item2 = create(:item, merchant: @merchant2)
      @item3 = create(:item, merchant: @merchant3)
      @item4 = create(:item, merchant: @merchant4)
      @item5 = create(:item, merchant: @merchant5)
      @item6 = create(:item, merchant: @merchant6)
      @item7 = create(:item, merchant: @merchant7)

      @invoice_items_m1 = create_list(:invoice_item, 5, unit_price: 5000, quantity: 5, merchant: @merchant1, invoice: @invoice1, item: @item1) #Total Revenue: 125000
      @invoice_items_m2 = create_list(:invoice_item, 5, unit_price: 2000, quantity: 3, merchant: @merchant2, invoice: @invoice2, item: @item2) #Total Revenue: 30000
      @invoice_items_m3 = create_list(:invoice_item, 5, unit_price: 4000, quantity: 6, merchant: @merchant3, invoice: @invoice3, item: @item3) #Total Revenue: 120000
      @invoice_items_m4 = create_list(:invoice_item, 5, unit_price: 3000, quantity: 3, merchant: @merchant4, invoice: @invoice4, item: @item4) #Total Revenue: 45000
      @invoice_items_m5 = create_list(:invoice_item, 5, unit_price: 2500, quantity: 3, merchant: @merchant5, invoice: @invoice5, item: @item5) #Total Revenue: 37500
      @invoice_items_m6 = create_list(:invoice_item, 10, unit_price: 10000, quantity: 8, merchant: @merchant6, invoice: @invoice6, item: @item6) #Total Revenue: 800000
      @invoice_items_m7 = create_list(:invoice_item, 1, unit_price: 500, quantity: 3, merchant: @merchant7, invoice: @invoice7, item: @item7) #Total Revenue: 1500

      create(:transaction, result: 1, invoice: @invoice1)
      create(:transaction, result: 1, invoice: @invoice2)
      create(:transaction, result: 1, invoice: @invoice3)
      create(:transaction, result: 1, invoice: @invoice4)
      create(:transaction, result: 1, invoice: @invoice5)
      create(:transaction, result: 0, invoice: @invoice6)
      create(:transaction, result: 1, invoice: @invoice7)
    end

    describe 'User Story 30' do
      it 'lists the top 5 merchants by total revenue generated and each merchant name links to the admin merchant show page and i see the total revenue generated next to each merchant' do
        visit admin_merchants_path

        within '#top_5_merchants_by_revenue' do
          expect(page).to have_content("#{@merchant1.name} - $1,250.00 in sales")
          expect(page).to have_content("#{@merchant3.name} - $1,200.00 in sales")
          expect(page).to have_content("#{@merchant4.name} - $450.00 in sales")
          expect(page).to have_content("#{@merchant5.name} - $375.00 in sales")
          expect(page).to have_content("#{@merchant2.name} - $300.00 in sales")

          expect("#{@merchant1.name} - $1,250.00 in sales").to appear_before("#{@merchant3.name} - $1,200.00 in sales", only_text: true)
          expect("#{@merchant3.name} - $1,200.00 in sales").to appear_before("#{@merchant4.name} - $450.00 in sales", only_text: true)
          expect("#{@merchant4.name} - $450.00 in sales").to appear_before("#{@merchant5.name} - $375.00 in sales", only_text: true)
          expect("#{@merchant5.name} - $375.00 in sales").to appear_before("#{@merchant2.name} - $300.00 in sales", only_text: true)

          expect(page).to have_link("#{@merchant1.name}", href: admin_merchant_path(@merchant1))
          expect(page).to have_link("#{@merchant2.name}", href: admin_merchant_path(@merchant2))
          expect(page).to have_link("#{@merchant3.name}", href: admin_merchant_path(@merchant3))
          expect(page).to have_link("#{@merchant4.name}", href: admin_merchant_path(@merchant4))
          expect(page).to have_link("#{@merchant5.name}", href: admin_merchant_path(@merchant5))

          expect(page).to_not have_content(@merchant6.name)
          expect(page).to_not have_content(@merchant7.name)
        end
      end
    end

    describe 'User Story 31' do
      it 'lists the date with the most revenue for each of the top 5 merchants and returns the most recent day if there are two days with the same' do
        invoice8 = create(:invoice, created_at: '1999-01-1 14:54:09')
        invoice9 = create(:invoice, created_at: '2024-03-27 14:54:09')
        invoice13 = create(:invoice, created_at: '2024-03-27 14:54:09')
        item8 = create(:item, merchant: @merchant1)
        create(:invoice_item, unit_price: 2500000, quantity: 10, merchant: @merchant1, invoice: invoice8, item: item8)
        create(:invoice_item, unit_price: 1250000, quantity: 10, merchant: @merchant1, invoice: invoice9, item: item8)
        create(:invoice_item, unit_price: 1250000, quantity: 10, merchant: @merchant1, invoice: invoice13, item: item8)
        create(:transaction, result: 1, invoice: invoice8)
        create(:transaction, result: 1, invoice: invoice9)
        create(:transaction, result: 1, invoice: invoice13)

        merchant9 = create(:merchant)
        invoice10 = create(:invoice, created_at: '2024-03-17 14:54:09')
        invoice11 = create(:invoice, created_at: '2024-03-18 14:54:09')
        invoice12 = create(:invoice, created_at: '2024-03-18 12:12:09')
        item9 = create(:item, merchant: merchant9)
        create(:invoice_item, unit_price: 200000, quantity: 5, merchant: merchant9, invoice: invoice10, item: item9)
        create(:invoice_item, unit_price: 190000, quantity: 5, merchant: merchant9, invoice: invoice11, item: item9)
        create(:invoice_item, unit_price: 190000, quantity: 5, merchant: merchant9, invoice: invoice12, item: item9)
        create(:transaction, result: 1, invoice: invoice10)
        create(:transaction, result: 1, invoice: invoice11)
        create(:transaction, result: 1, invoice: invoice12)

        visit admin_merchants_path

        within '#top_5_merchants_by_revenue' do
          expect(page).to have_content("Top day for #{@merchant1.name} was 03/27/24")
          expect(page).to have_content("Top day for #{merchant9.name} was 03/18/24")
        end
      end
    end
  end
end
