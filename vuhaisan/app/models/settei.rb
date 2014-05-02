class Settei
  include Mongoid::Document

  field :delivery_method, type: String
  field :payment_at_delivery, type: String
  field :payment_bank_transfer, type: String
  field :payment_vtc_pay, type: String
  field :steps_desc, type: String

end