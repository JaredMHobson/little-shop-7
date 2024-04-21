require 'rails_helper'

RSpec.describe 'Merchant Coupons Index Page' do
  describe 'User Story 1 Solo' do
    it 'lists all of my coupon names including their amount off and each coupons name is also a link to its show page' do
      merchant1 = create(:merchant)
      coupon_list = create_list(:coupon, 5, merchant: merchant1)

      merchant2 = create(:merchant)
      coupon2 = create(:coupon, merchant: merchant2)

      visit merchant_coupons_path(merchant1)

      coupon_list.each do |coupon|
        expect(page).to have_content(coupon.name)
        expect(page).to have_link(coupon.name, href: merchant_coupon_path(merchant1, coupon))

        if coupon.coupon_type == "percent"
          expect(page).to have_content("Amount: #{coupon.amount}% off")
        else
          expect(page).to have_content("Amount: $#{(coupon.amount / 100.0).round(2)} off")
        end
      end

      expect(page).to_not have_content(coupon2.name)
    end
  end

  describe 'User Story 2 Solo' do
    it 'lists all of my coupon names including their amount off and each coupons name is also a link to its show page' do
      merchant1 = create(:merchant)

      visit merchant_coupons_path(merchant1)

      expect(page).to have_link("Create new coupon", href: new_merchant_coupon_path(merchant1))

      click_link("Create new coupon")

      expect(current_path).to eq(new_merchant_coupon_path(merchant1))
    end
  end
end