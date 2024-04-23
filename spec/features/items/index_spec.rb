require 'rails_helper'

RSpec.describe 'Merchant Items Index' do
  before :each do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)

    @table = create(:item, name: "table", merchant: @merchant1, status: 0)
    @pen = create(:item, name: "pen", merchant: @merchant1, status: 0)
    @mat = create(:item, name: "yoga mat", merchant: @merchant1, status: 0)
    @mug = create(:item, name: "mug", merchant: @merchant1, status: 1)
    @ember = create(:item, name: "ember", merchant: @merchant2, status: 1)
    @plant = create(:item, name: "plant", merchant: @merchant2, status: 1)

    visit merchant_items_path(@merchant1)
  end

  describe 'User story 6' do
    it 'displays a list of the names of a specific merchants items' do
      expect(page).to have_content(@table.name)
      expect(page).to have_content(@pen.name)
      expect(page).to have_content(@mat.name)
      expect(page).to have_content(@mug.name)
      
      expect(page).to_not have_content(@ember.name)
      expect(page).to_not have_content(@plant.name)
    end
  end

  describe "User story 7a" do
    it 'has a link for each item' do
      expect(page).to have_link("#{@mug.name}", href: merchant_item_path(@merchant1, @mug))
      expect(page).to have_link("#{@table.name}", href: merchant_item_path(@merchant1, @table))
      expect(page).to have_link("#{@pen.name}", href: merchant_item_path(@merchant1, @pen))
      expect(page).to have_link("#{@mat.name}", href: merchant_item_path(@merchant1, @mat))
      expect(page).not_to have_link("#{@ember.name}", href: merchant_item_path(@merchant1, @ember))

      click_link @table.name
      expect(current_path).to eq(merchant_item_path(@merchant1, @table))
    end
  end

  describe "User Story 9" do
    it "can enable/disable items" do
      within ".enabled_items .enabled_item-#{@mug.id}" do
        expect(page).to have_content(@mug.name)
        expect(page).to have_button("Disable #{@mug.name}")
        expect(page).to_not have_button("Enable #{@mug.name}")
        click_button("Disable #{@mug.name}")
        expect(current_path).to eq(merchant_items_path(@merchant1))
      end

      within ".enabled_items" do
        expect(page).to_not have_content(@mug.name)
      end

      within ".disabled_items .disabled_item-#{@pen.id}" do
        expect(page).to have_content(@pen.name)
        expect(page).to have_button("Enable #{@pen.name}")
        expect(page).to_not have_button("Disable #{@pen.name}")
        click_button("Enable #{@pen.name}")
        expect(current_path).to eq(merchant_items_path(@merchant1))
      end
      
      within ".disabled_items" do
        expect(page).to_not have_content(@pen.name)
      end
    end
  end
     
  describe 'User Story 10' do
    it 'displays items grouped by enabled and disabled' do
      within '.enabled_items' do
        @merchant1.items.enabled.each do |item|
          expect(page).to have_content(@mug.name)
          expect(page).to_not have_content(@mat.name)
        end
      end
      
      within '.disabled_items' do
        @merchant1.items.each do |item|
          expect(page).to_not have_content(@mug.name)
          expect(page).to have_content(@mat.name)
          expect(page).to have_content(@pen.name)
          expect(page).to have_content(@table.name)
        end
      end
    end
  end

  describe 'User Story 11' do
    it 'displays a link to create a new item' do
      # When I visit my items index page
      # I see a link to create a new item.
      expect(page).to have_link("Create new item for #{@merchant1.name}")
      # When I click on the link,
      click_link("Create new item for #{@merchant1.name}")
      # I am taken to a form that allows me to add item information.
      expect(current_path).to eq(new_merchant_item_path(@merchant1))
      # When I fill out the form I click ‘Submit’
      fill_in 'Name:', with: 'Something that costs more than it should'
      fill_in 'Description:', with: 'It is literally made from trash'
      fill_in 'Unit Price:', with: 1111
      click_on "Submit"
      # Then I am taken back to the items index page
      expect(current_path).to eq(merchant_items_path(@merchant1))
      # And I see the item I just created displayed in the list of items.
      # And I see my item was created with a default status of disabled.
      within ".disabled_items" do
        expect(page).to have_content("Something that costs more than it should")
      end
    end
  end

  describe "User Story 13" do
    it "The 5 most popular items dates" do
      merchant9 = create(:merchant)

      invoice8 = create(:invoice, created_at: '1999-01-1 14:54:09')
      invoice9 = create(:invoice, created_at: '2024-03-27 14:54:09')
      invoice13 = create(:invoice, created_at: '2024-03-27 14:54:09')

      create(:transaction, result: 1, invoice: invoice8)
      create(:transaction, result: 1, invoice: invoice9)
      create(:transaction, result: 1, invoice: invoice13)

      invoice10 = create(:invoice, created_at: '2024-03-17 14:54:09')
      invoice11 = create(:invoice, created_at: '2024-03-18 14:54:09')
      invoice12 = create(:invoice, created_at: '2024-03-18 12:12:09')

      item9 = create(:item, merchant: merchant9)
      item10 = create(:item, merchant: merchant9)
      item11 = create(:item, merchant: merchant9)
      item12 = create(:item, merchant: merchant9)
      item13 = create(:item, merchant: merchant9)
      item14 = create(:item, merchant: merchant9)

      create(:invoice_item, unit_price: 200000, quantity: 23, merchant: merchant9, invoice: invoice10, item: item10)
      create(:invoice_item, unit_price: 190000, quantity: 14, merchant: merchant9, invoice: invoice11, item: item9)
      create(:invoice_item, unit_price: 190000, quantity: 44, merchant: merchant9, invoice: invoice12, item: item12)
      create(:transaction, result: 1, invoice: invoice10)
      create(:transaction, result: 1, invoice: invoice11)
      create(:transaction, result: 0, invoice: invoice12)

      visit merchant_items_path(merchant9)

      within '.top_selling_items' do
        expect(page).to have_content(item10.name)
        expect(page).to have_content("03/17/24")

        expect(page).to have_content(item9.name)
        expect(page).to have_content("03/18/24")

        expect(page).to_not have_content(item12.name)
      end
    end
  end
end
