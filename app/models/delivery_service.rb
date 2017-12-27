# DeliveryService Documentation
#
# The delivery_service table contains a list of available delivery services, with detailed service data.
# A delivery service can have many delivery service prices.
# == Schema Information
#
# Table name: delivery_services
#
#  id                  :integer          not null, primary key
#  name                :string
#  description         :string
#  courier_name        :string
#  created_at          :datetime
#  updated_at          :datetime
#  active              :boolean          default(TRUE)
#  order_price_minimum :decimal(8, 2)    default(0.0)
#  order_price_maximum :decimal(8, 2)
#  tracking_url        :string
#

class DeliveryService < ActiveRecord::Base
  include ActiveScope

  attr_accessible :name, :description, :courier_name, :order_price_minimum, :order_price_maximum, :active, :country_ids, :tracking_url

  has_many :prices, class_name: 'DeliveryServicePrice', dependent: :destroy
  has_many :active_prices, -> { where(active: true).order(price: :asc) }, class_name: 'DeliveryServicePrice'
  has_many :destinations, dependent: :destroy
  has_many :countries,    through: :destinations
  has_many :orders,       through: :prices

  validates :name, :courier_name, presence: true
  validates :name,                uniqueness: { scope: [:active, :courier_name] }
  validates :description,         length: { maximum: 180, message: :too_long }

  default_scope { order(courier_name: :desc) }

  # Returns a string of the courier_name and name attributes concatenated
  #
  # @return [String] courier and name
  def full_name
    [courier_name, name].join(' ')
  end
end
