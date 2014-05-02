require 'digest'
require 'base64'

module PaymentHelper
  
  def get_vtc_pay_url(order)
    order_code = order.code
    amount = order.sum

    sign = encrypt_array([
      VTC_PAY_WEBSITE_ID,
      VTC_PAY_PAYMENT_METHOD,
      order_code,
      amount,
      VTC_PAY_RECEIVER_ACC,
      VTC_PARAM_EXTEND,
      VTC_PAY_SECRET
    ])

    "#{VTC_PAY_BASE_URL}" +
    "?website_id=#{VTC_PAY_WEBSITE_ID}" +
    "&payment_method=#{VTC_PAY_PAYMENT_METHOD}" +
    "&order_code=#{order_code}" +
    "&amount=#{amount}" +
    "&receiver_acc=#{VTC_PAY_RECEIVER_ACC}" +
    "&param_extend=#{VTC_PARAM_EXTEND}" +
    "&sign=#{sign}"
  end

  def check_sign(status, order_code, amount, server_sign)
    server_sign == encrypt_array([
      status,
      VTC_PAY_WEBSITE_ID,
      order_code,
      amount,
      VTC_PAY_SECRET
    ])
  end


  def encrypt_array(arr)
    Digest::SHA256.hexdigest(arr.join("-")).upcase
  end
end