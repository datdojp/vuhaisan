class User
  include Mongoid::Document

  field :fb_id, type: String
  field :name, type: String
  field :address, type: String
  field :phone, type: String
  field :email, type: String

  has_many :orders, class_name: Order.name, inverse_of: :user

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
end