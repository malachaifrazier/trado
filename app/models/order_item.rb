# OrderItem Documentation
#
# The order item table represents each item within an order.
# They reference further data from the SKU table and are persisted for as long as the order it's associated with is present.
# == Schema Information
#
# Table name: order_items
#
#  id         :integer          not null, primary key
#  price      :decimal(8, 2)
#  quantity   :integer
#  sku_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :integer
#  weight     :decimal(8, 2)
#

class OrderItem < ActiveRecord::Base
  attr_accessible :price, :quantity, :sku_id, :order_id, :weight

  belongs_to :sku
  belongs_to :order

  has_one :order_item_accessory, dependent: :delete
  has_one :product,              through: :sku

  # Calculates the total price of an order item by multipling the item price by it's quantity
  #
  # @return [Decimal] total price of cart item
  def total_price
    price * quantity
  end
end
