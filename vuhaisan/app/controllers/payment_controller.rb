class PaymentController < ApplicationController

  include PaymentHelper
  include ClientHelper

  before_filter :prepare_categories
  before_filter :prepare_cart
  before_filter :prepare_profile

  layout "client"

  def vtc
    order_code = params[:order_code]
    status = params[:status].to_i
    amount = params[:amount].to_i
    website_id = params[:website_id]
    sign = params[:sign]

    @order = Order.where(code: order_code).first
    
    @error = nil
    if !@order
      @error = I18n.t "client.payment.vtc.order_not_exist"
    elsif @order.step >= Order::STEP_PAID
      @message = I18n.t "client.payment.vtc.order_already_paid"
    elsif status == 2
      @error = I18n.t "client.payment.vtc.transaction_being_held"
    elsif status == 0
      @error = I18n.t "client.payment.vtc.transaction_being_processed"
    elsif status == -1
      @error = I18n.t "client.ayment.vtc.failed"
    elsif status == -5
      @error = I18n.t "client.payment.vtc.invalid_order_code"
    elsif status == -6
      @error = I18n.t "client.ayment.vtc.balance_not_enough"
    elsif status == 1
      if amount != @order.sum
        @error = I18n.t "client.payment.vtc.invalid_amout"
      elsif website_id != VTC_PAY_WEBSITE_ID
        @error = I18n.t "client.payment.vtc.invalid_website_id"
      elsif !check_sign(status, order_code, amount, sign)
        @error = I18n.t "client.payment.vtc.invalid_sign"
      else
        @message = I18n.t "client.payment.vtc.success"
      end
    end

    if !@error
      if @order
        @order.step = Order::STEP_PAID
        @order.payment_failure_reason = nil
      end
    else
      @order.payment_failure_reason = @error
    end

    if @order
      if @order.should_mail?
        UserMailer.order_changed_email(@order).deliver
      end
      @order.save
    end

    @title = I18n.t("client.message")
    render "client/message"
  end
end