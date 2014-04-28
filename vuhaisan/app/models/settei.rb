class Settei
  include Mongoid::Document

  field :delivery_method, type: String
  field :payment_at_delivery, type: String
  field :payment_bank_transfer, type: String

end