require 'rails_helper'

RSpec.describe 'Merchant Coupon New Page' do
  describe 'User Story 2 Solo' do
    it 'has a form to add a new coupon and when I fill it in with a name, unique code, an amount, and type and I click submit I am taken back to my coupon index page and see my coupon. Returns an error message if code is not unique' do
      merchant1 = create(:merchant)
      coupon_list = create_list(:coupon, 5, merchant: merchant1)

      visit merchant_coupons_path(merchant1)

      expect(page).to_not have_content('Random Cool Coupon Name')
      expect(page).to_not have_content('100% off')

      visit new_merchant_coupon_path(merchant1)

      expect(page).to have_selector('form')

      fill_in('Name:', with: 'Random Cool Coupon Name')
      fill_in('Unique Code:', with: 'RCCN100')
      fill_in(:amount, with: '100')
      choose(option: 'percent')
      click_button('Submit')

      expect(current_path).to eq(merchant_coupons_path(merchant1))

      within '#disabled_coupons' do
        expect(page).to have_content('Random Cool Coupon Name')
        expect(page).to have_content('100% off')
      end

      visit new_merchant_coupon_path(merchant1)

      fill_in('Name:', with: 'New Coupon Name')
      fill_in('Unique Code:', with: 'RCCN100')
      fill_in(:amount, with: '50')
      choose(option: 'dollar')
      click_button('Submit')

      expect(page).to have_content("Error: Code has already been taken")
    end
  end
end