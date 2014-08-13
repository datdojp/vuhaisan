class UserMailer < ActionMailer::Base
  default from: 'no-reply@pari.vn', return_path: 'no-reply@pari.vn'

  def order_changed_email(order)
    @order = order
    mail to: order.email, cc: [ADMIN_EMAIL_ADDRESS]
  end
end
