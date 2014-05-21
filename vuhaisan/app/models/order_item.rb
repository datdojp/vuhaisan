class OrderItem
  include Mongoid::Document

  field :name, type: String
  field :unit, type: String
  field :price, type: Integer
  field :quantity, type: Integer
  field :custom_field_values, type: Array, default: []

  belongs_to :product, class_name: Product.name, inverse_of: :order_items
  belongs_to :order, class_name: Order.name, inverse_of: :items

  def total
  	if price and quantity
      price * quantity
    else
      0
    end
  end

  def unit_as_text
    Product.get_unit_text unit
  end

  def custom_field_values_as_text
    custom_field_values.join(', ')
  end
end