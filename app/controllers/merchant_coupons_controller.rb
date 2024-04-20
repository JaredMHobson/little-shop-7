class MerchantCouponsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @enabled_coupons = @merchant.coupons.enabled
    @disabled_coupons = @merchant.coupons.disabled
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])

    coupon = @merchant.coupons.new(coupon_params)

    if coupon.save
      redirect_to merchant_coupons_path(@merchant)
    else
      flash[:alert] = "Error: #{coupon.errors.full_messages.to_sentence}"

      redirect_to new_merchant_coupon_path(@merchant)
    end
  end

  private
  def coupon_params
    params.permit(
      :name,
      :code,
      :amount,
      :coupon_type
    )
  end
end