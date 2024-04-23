require 'rails_helper'

RSpec.describe 'Merchant Coupons Index Page' do
  describe 'User Story 1 Solo' do
    it 'lists all of my coupon names including their amount off and each coupons name is also a link to its show page' do
      merchant1 = create(:merchant)
      coupon_list = create_list(:coupon, 5, merchant: merchant1)

      percent_coupon = create(:coupon, coupon_type: 0, merchant: merchant1)
      dollar_coupon = create(:coupon, coupon_type: 1, merchant: merchant1)

      merchant2 = create(:merchant)
      coupon2 = create(:coupon, merchant: merchant2)

      visit merchant_coupons_path(merchant1)

      coupon_list.each do |coupon|
        expect(page).to have_content(coupon.name)
        expect(page).to have_link(coupon.name, href: merchant_coupon_path(merchant1, coupon))
        expect(page).to have_content("Amount: #{coupon.formatted_amount} Off")
      end

      expect(page).to have_content(percent_coupon.name)
      expect(page).to have_link(percent_coupon.name, href: merchant_coupon_path(merchant1, percent_coupon))
      expect(page).to have_content("Amount: #{percent_coupon.formatted_amount} Off")

      expect(page).to have_content(dollar_coupon.name)
      expect(page).to have_link(dollar_coupon.name, href: merchant_coupon_path(merchant1, dollar_coupon))
      expect(page).to have_content("Amount: #{dollar_coupon.formatted_amount} Off")

      expect(page).to_not have_content(coupon2.name)
    end
  end

  describe 'User Story 2 Solo' do
    it 'has a link to create a new coupon and when I click that link I am taken to my new coupon page' do
      merchant1 = create(:merchant)

      visit merchant_coupons_path(merchant1)

      expect(page).to have_link("Create new coupon", href: new_merchant_coupon_path(merchant1))

      click_link("Create new coupon")

      expect(current_path).to eq(new_merchant_coupon_path(merchant1))
    end
  end

  describe 'User Story 6 Solo' do
    it 'separates my coupons between enabled and disabled coupons' do
      merchant1 = create(:merchant)
      coupon_list = create_list(:coupon, 4, merchant: merchant1)
      enabled_coupon = create(:coupon, merchant: merchant1, status: 1)
      disabled_coupon = create(:coupon, merchant: merchant1, status: 0)

      visit merchant_coupons_path(merchant1)

      within '#enabled_coupons' do
        coupon_list.each do |coupon|
          expect(page).to have_content(coupon.name) if coupon.enabled?
        end

        expect(page).to have_content(enabled_coupon.name)
        expect(page).to_not have_content(disabled_coupon.name)
      end

      within '#disabled_coupons' do
        coupon_list.each do |coupon|
          expect(page).to have_content(coupon.name) if coupon.disabled?
        end

        expect(page).to have_content(disabled_coupon.name)
        expect(page).to_not have_content(enabled_coupon.name)
      end
    end
  end

  describe 'Extension Story Solo 1' do
    it 'lists enabled and disabled coupons and they are sorted in order of popularity, from most to least. it sorts by ascending ID if usage is equal' do
      merchant1 = create(:merchant)

      coupon1 = create(:coupon, merchant: merchant1, status: 1) #4
      coupon2 = create(:coupon, merchant: merchant1, status: 0) #2
      coupon3 = create(:coupon, merchant: merchant1, status: 1) #0
      coupon4 = create(:coupon, merchant: merchant1, status: 1) #5
      coupon5 = create(:coupon, merchant: merchant1, status: 1) #3
      coupon6 = create(:coupon, merchant: merchant1, status: 0) #1
      coupon7 = create(:coupon, merchant: merchant1, status: 1) #0
      coupon8 = create(:coupon, merchant: merchant1, status: 0) #4
      coupon9 = create(:coupon, merchant: merchant1, status: 1) #2

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
      invoice16 = create(:invoice, coupon: coupon6)
      invoice17 = create(:invoice, coupon: coupon8)
      invoice18 = create(:invoice, coupon: coupon8)
      invoice19 = create(:invoice, coupon: coupon8)
      invoice20 = create(:invoice, coupon: coupon8)
      invoice21 = create(:invoice, coupon: coupon9)
      invoice22 = create(:invoice, coupon: coupon9)

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
      create(:transaction, result: 0, invoice: invoice16)
      create(:transaction, result: 0, invoice: invoice16)
      create(:transaction, result: 0, invoice: invoice16)
      create(:transaction, result: 1, invoice: invoice16)
      create(:transaction, result: 1, invoice: invoice17)
      create(:transaction, result: 1, invoice: invoice18)
      create(:transaction, result: 1, invoice: invoice19)
      create(:transaction, result: 1, invoice: invoice20)
      create(:transaction, result: 0, invoice: invoice21)
      create(:transaction, result: 1, invoice: invoice21)
      create(:transaction, result: 1, invoice: invoice22)

      visit merchant_coupons_path(merchant1)

      within '#enabled_coupons' do
        expect(coupon4.name).to appear_before(coupon1.name)
        expect(coupon1.name).to appear_before(coupon5.name)
        expect(coupon5.name).to appear_before(coupon9.name)
        expect(coupon9.name).to appear_before(coupon3.name)
        expect(coupon3.name).to appear_before(coupon7.name)

        expect(page).to_not have_content(coupon8.name)
        expect(page).to_not have_content(coupon2.name)
      end

      within '#disabled_coupons' do
        expect(coupon8.name).to appear_before(coupon2.name)
        expect(coupon2.name).to appear_before(coupon6.name)

        expect(page).to_not have_content(coupon1.name)
        expect(page).to_not have_content(coupon4.name)
      end
    end
  end
end
