require 'digest'
require 'base64'

module PaymentHelper
  
  def get_vtc_pay_url(order)
    order_code = order.code
    amount = order.sum

    sign = get_sign order_code, amount

    "#{VTC_PAY_BASE_URL}" +
    "?website_id=#{VTC_PAY_WEBSITE_ID}" +
    "&payment_method=#{VTC_PAY_PAYMENT_METHOD}" +
    "&order_code=#{order_code}" +
    "&amount=#{amount}" +
    "&receiver_acc=#{VTC_PAY_RECEIVER_ACC}" +
    "&param_extend=#{VTC_PARAM_EXTEND}" +
    "&sign=#{sign}"
  end

  def check_sign(order_code, amount, server_sign)
    server_sign == get_sign(order_code, amount)
  end

  def get_sign(order_code, amount)
    data = [
      VTC_PAY_WEBSITE_ID,
      VTC_PAY_PAYMENT_METHOD,
      order_code,
      amount,
      VTC_PAY_RECEIVER_ACC,
      VTC_PARAM_EXTEND,
      VTC_PAY_SECRET
    ].join "-"
    Digest::SHA256.hexdigest(data).upcase
  end
end