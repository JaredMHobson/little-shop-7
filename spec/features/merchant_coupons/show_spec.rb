require 'rails_helper'

RSpec.describe 'Merchant Coupon Show Page' do
  describe 'User Story 3 Solo' do
    it 'shows that coupons name and code and the amount off value as well as its status and a count of how many times that coupon has been used' do
      merchant1 = create(:merchant)
      coupon1 = create(:coupon, merchant: merchant1, name: 'Half Off', code: '50OFF', coupon_type: 'percent', amount: 50, status: 0)
      coupon2 = create(:coupon, merchant: merchant1, name: 'Save $10 On All Shoes', code: '10OFF', coupon_type: 'dollar', amount: 1000, status: 1)

      invoice1 = create(:invoice, coupon: coupon1)
      invoice2 = create(:invoice, coupon: coupon2)
      invoice3 = create(:invoice, coupon: coupon2)
      invoice4 = create(:invoice, coupon: coupon1)
      invoice5 = create(:invoice, coupon: coupon1)
      invoice6 = create(:invoice, coupon: coupon1)

      create(:transaction, result: 1, invoice: invoice1)
      create(:transaction, result: 1, invoice: invoice2)
      create(:transaction, result: 1, invoice: invoice3)
      create(:transaction, result: 0, invoice: invoice4)
      create(:transaction, result: 1, invoice: invoice5)
      create(:transaction, result: 1, invoice: invoice6)

      visit merchant_coupon_path(merchant1, coupon1)

      expect(page).to have_content('Half Off')
      expect(page).to have_content('Code: 50OFF')
      expect(page).to have_content('Amount: 50% Off')
      expect(page).to have_content('Status: Disabled')
      expect(page).to have_content('Times Used: 3')

      visit merchant_coupon_path(merchant1, coupon2)

      expect(page).to have_content('Save $10 On All Shoes')
      expect(page).to have_content('Code: 10OFF')
      expect(page).to have_content('Amount: $10.00 Off')
      expect(page).to have_content('Status: Enabled')
      expect(page).to have_content('Times Used: 2')
    end
  end

  describe 'User Story 4 Solo' do
    it 'has a disable button next to my enabled coupons on their show page and when i click that button, im taken back to the coupon show page and see that the status is now disabled. This coupon cannot be disabled if there is a pending invoice with it' do 
      merchant1 = create(:merchant)
      coupon1 = create(:coupon, merchant: merchant1, status: 1)
      coupon2 = create(:coupon, merchant: merchant1, status: 1)

      create(:invoice, coupon: coupon2, status: 0)

      visit merchant_coupon_path(merchant1, coupon1)

      expect(page).to have_content('Status: Enabled')
      expect(page).to have_button('Disable')

      click_button('Disable')

      expect(current_path).to eq(merchant_coupon_path(merchant1, coupon1))

      expect(page).to have_content('Status: Disabled')

      visit merchant_coupon_path(merchant1, coupon2)

      expect(page).to have_content('Status: Enabled')
      expect(page).to have_button('Disable', disabled: true)
    end
  end

  describe 'User Story 5 Solo' do
    it 'has an enable button next to my disabled coupons on their show page and when i click that button, im taken back to the coupon show page and see that the status is now enabled. This coupon cannot be enabled if there are already 5 enabled coupons for this merchant' do 
      merchant1 = create(:merchant)
      coupon1 = create(:coupon, merchant: merchant1, status: 1)
      coupon2 = create(:coupon, merchant: merchant1, status: 1)
      coupon3 = create(:coupon, merchant: merchant1, status: 1)
      coupon4 = create(:coupon, merchant: merchant1, status: 1)
      coupon5 = create(:coupon, merchant: merchant1, status: 0)
      coupon6 = create(:coupon, merchant: merchant1, status: 0)

      visit merchant_coupon_path(merchant1, coupon5)

      expect(page).to have_content('Status: Disabled')
      expect(page).to have_button('Enable')

      click_button('Enable')

      expect(current_path).to eq(merchant_coupon_path(merchant1, coupon5))

      expect(page).to have_content('Status: Enabled')

      visit merchant_coupon_path(merchant1, coupon6)

      expect(page).to have_content('Status: Disabled')
      expect(page).to have_button('Enable', disabled: true)

      visit merchant_coupon_path(merchant1, coupon1)

      click_button('Disable')

      visit merchant_coupon_path(merchant1, coupon6)

      expect(page).to have_content('Status: Disabled')
      expect(page).to have_button('Enable', disabled: false)
    end
  end
end