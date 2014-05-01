class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  STEP_CARTING = 100
  STEP_SENT = 200
  STEP_PAID = 300
  STEP_DELIVERING = 400
  STEP_FINISHED = 500
  STEP_CANCELED = 600

  PAYMENT_AT_DELIVERIED = 1
  PAYMENT_BANK_TRANSFER = 2
  PAYMENT_VTC_PAY = 3

  field :step, type: Integer, default: STEP_CARTING

  field :name, type: String
  field :email, type: String
  field :address, type: String
  field :phone, type: String

  field :payment, type: Integer, default: PAYMENT_AT_DELIVERIED
  field :payment_failure_reason, type: String

  field :ship_cost, type: Integer, default: 0

  field :code, type: String

  field :data, type: String
  field :flattened_data, type: String

  field :history, type: Array

  has_many :items, class_name: OrderItem.name, inverse_of: :order, autosave: true
  belongs_to :user, class_name: User.name, inverse_of: :orders

  before_create do |document|
    document.code = SecureRandom.hex(3)
  end

  before_save do |document|
    a = get_search_data document, [
      :name, :email, :address, :phone,
      :step_as_text, :payment_as_text,
      :desc,:payment_failure_reason, :code,
      :user_facebook_id]
    document.data = a[0]
    document.flattened_data = a[1]

    if document.step_changed?
      document.history ||= []
      document.history << [document.step, Time.now]
    end
  end

  def sum
    ret = 0
    if items
      items.each do |i|
        ret += i.total
      end
    end
    ret += ship_cost
    ret
  end

  def sum_quantity
    ret = 0
    if items
      items.each do |i|
        ret += i.quantity
      end
    end
    ret
  end

  def desc
    if !items
      ""
    else
      ret = ""
      items.each_with_index do |item, index|
        if index > 0
          ret = "#{ret}, "
        end
        ret = "#{ret}#{item.name}(#{item.quantity} #{item.unit_as_text})"
      end
      ret
    end
  end

  def self.get_step_as_text(step)
    if step == STEP_CARTING
      I18n.t("client.order.step.carting")
    elsif step == STEP_SENT
      I18n.t("client.order.step.sent")
    elsif step == STEP_PAID
      I18n.t("client.order.step.paid")
    elsif step == STEP_DELIVERING
      I18n.t("client.order.step.delivering")
    elsif step == STEP_FINISHED
      I18n.t("client.order.step.finished")
    elsif step == STEP_CANCELED
      I18n.t("client.order.step.canceled")
    else
      ""
    end
  end

  def step_as_text
    Order.get_step_as_text step
  end

  def self.get_payment_as_text(payment)
    if payment == Order::PAYMENT_AT_DELIVERIED
      I18n.t "client.pay_at_delivery"
    elsif payment == Order::PAYMENT_BANK_TRANSFER
      I18n.t "client.pay_bank_transfer"
    elsif payment == Order::PAYMENT_VTC_PAY
      I18n.t "client.pay_vtc"
    else
      ""
    end
  end

  def payment_as_text
    self.class.get_payment_as_text payment
  end

  def self.general_search(keyword)
    Order.where get_search_criteria(keyword)
  end

  def user_facebook_id
    if user
      user.fb_id
    else
      nil
    end
  end

  def should_mail?
    if !email || email.length == 0 || !changed? || step == STEP_CARTING
      return false
    end

    return step_changed? || name_changed? || email_changed? || address_changed? || phone_changed? ||
        payment_changed? || ship_cost_changed?
  end
end