class CouponsController < ApplicationController
  def index
    # require 'pry'; binding.pry
    @merchant = Merchant.find(params[:merchant_id])
    @merchant_coupons = @merchant.coupons.all
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = Coupon.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @merchant_coupon = @merchant.coupons.new(coupon_params)
      if @merchant_coupon.save
        flash[:success] = "Coupon created successfully."
        redirect_to merchant_coupons_path(@merchant)
      else
        flash.now[:error] = @merchant_coupon.errors.full_messages.join(", ")
        render :new
      end
  end

  def update
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = @merchant.coupons.find(params[:id])
    
    if params[:new_status]
      @coupon.update(status: params[:new_status])
      redirect_to merchant_coupon_path(@merchant, @coupon)
    # elsif params[:name].present?
    #   if @coupon.update(coupon_params)
    #     flash[:notice] = "#{@coupon.name} info updated successfully."
    #     redirect_to merchant_coupon_path(@merchant, @coupon)
    #   end
    end
  end
  
  private

  def coupon_params
    params.permit(:name, :code, :discount_amount, :percent_off, :status)
  end
end