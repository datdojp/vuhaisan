class User
  include Mongoid::Document

  field :fb_id, type: String
  field :name, type: String
  field :address, type: String
  field :phone, type: String
  field :email, type: String

  field :data, type: String
  field :flattened_data, type: String

  has_many :orders, class_name: Order.name, inverse_of: :user

  before_save do |document|
    a = get_search_data document, [
      :fb_id, :name, :email, :address, :phone]
    document.data = a[0]
    document.flattened_data = a[1]
  end

  def order_count_for_each_step
  	ret = {}
  	ret[Order::STEP_CARTING] = 0
    ret[Order::STEP_SENT] = 0
    ret[Order::STEP_PAID] = 0
    ret[Order::STEP_DELIVERING] = 0
    ret[Order::STEP_FINISHED] = 0
    ret[Order::STEP_CANCELED] = 0

    if orders
      orders.each do |o|
      	ret[o.step] += 1
      end
    end

    ret
  end

  def order_count
  	if orders
  	  orders.length
  	else
  	  0
  	end
  end

  def self.general_search(keyword)
    User.where get_search_criteria(keyword)
  end
end