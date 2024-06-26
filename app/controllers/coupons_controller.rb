class CouponsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @enabled_coupons = @merchant.coupons.enabled_sorted_by_popularity
    @disabled_coupons = @merchant.coupons.disabled_sorted_by_popularity
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

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = Coupon.find(params[:id])
  end

  def update
    @coupon = Coupon.find(params[:id])

    if params[:status].present?
      @coupon.update(status: params[:status])

      redirect_to merchant_coupon_path(params[:merchant_id], @coupon)
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
