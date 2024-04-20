class ChangeColumnCoupons < ActiveRecord::Migration[7.1]
  def change
    rename_column :coupons, :type, :coupon_type
  end
end
