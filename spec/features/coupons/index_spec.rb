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
end
