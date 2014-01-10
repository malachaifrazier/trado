class Cart < ActiveRecord::Base
  has_many :line_items, :dependent => :delete_all # A cart has many lineitems, however it is dependent on them. it will not be destroyed if a lineitem still exists within it

  def add_product(product_id, sku_price, sku_id, sku_length, sku_thickness, sku_weight, sku, attribute_value, attribute_type, attribute_measure, item_quantity)
  	current_item = line_items.where('product_id = ?', product_id).where('sku_id = ?', sku_id).first #grabs all the products which match the product id
    if current_item
  		current_item.quantity += item_quantity.to_i #if line item selected exists, increment its quantity by 1
      current_item.weight += sku_weight
  	else 
      current_item = line_items.build(:product_id => product_id, :price => sku_price, :sku_id => sku_id, :length => sku_length, :thickness => sku_thickness, :weight => sku_weight, :sku => sku, :attribute_value => attribute_value, :attribute_type => attribute_type, :attribute_measurement => attribute_measure) #if line item selected does not exist, build a new cart item
      if item_quantity.to_i > 1
        current_item.quantity += (item_quantity.to_i-1)
      end
  	end
  	current_item #return new item either by quantity or new cart item
  end
  def decrement_line_item_quantity(line_item_id)
    current_item = line_items.find(line_item_id)
    if current_item.quantity > 1
      current_item.quantity -= 1
    else
      current_item.destroy
    end
    current_item
  end

  def total_price 
  	line_items.to_a.sum { |item| item.total_price }
  end

  def basket_quantity(cart)
    cart.line_items.each do |item|
      basket_quantity << item.quantity
    end
    basket_quantity
  end

  def calculate_shipping_tier
      max_length = self.line_items.map(&:length).max
      max_thickness = self.line_items.map(&:thickness).max
      total_weight = self.line_items.map(&:weight).sum
      # FIXME: Possibly quite slow. Alot of repetition here so will revise later
      tier_raffle = []
      tier_raffle << Tier.where('? >= length_start AND ? <= length_end',max_length, max_length).pluck(:id)
      tier_raffle << Tier.where('? >= thickness_start AND ? <= thickness_end', max_thickness, max_thickness).pluck(:id)
      tier_raffle << Tier.where('? >= weight_start AND ? <= weight_end', total_weight, total_weight).pluck(:id)
      return tier_raffle.max.first
  end

  def clear_carts
    Cart.where("updated_at < ?", 12.hours.ago).destroy_all
  end
end
