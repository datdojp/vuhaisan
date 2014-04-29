class ClientController < ApplicationController

  include PaymentHelper
  include ClientHelper

  before_filter :prepare, only: [
    :home,
    :product_detail,
    :cart_detail,
    :profile,
    :add_to_cart,
    :add_to_cart_remote,
    :remove_from_cart_remote,
    :pay,
    :order
  ]
  before_filter :prepare_profile, only: [
    :profile,
    :update_profile,
    :cart_detail,
    :pay,
    :order
  ]

  layout "client"

  def prepare
    prepare_categories
    prepare_cart
  end

  def home
    @keyword = params[:keyword]
    if @keyword && @keyword.length > 0
      criteria = Product.general_search @keyword
    else
      criteria = Product.where(category_id: @category_id)
    end

    @products = criteria.page(params[:page]).per(10)
    @title = I18n.t("client.home")
    render "client/home"
  end

  def product_detail
    id = params[:id]
    @product = Product.where(id: id).first
    @title = @product.name
    if !@product
      redirect_to client_home_path
    else
      render "client/product_detail"
    end 
  end

  def add_to_cart
    common_add_to_cart
    redirect_to client_home_path(category_id: @category_id)
  end

  def add_to_cart_remote
    common_add_to_cart
    render "client/remote/add_to_cart_remote", layout: nil
  end

  def common_add_to_cart
    product = Product.where(id: params[:product_id]).first
    quantity = params[:quantity].to_i

    # check if product is already added
    existing_item = nil
    @cart.items.each do |i|
      if i.product_id == product.id && i.unit == product.unit && i.price == product.price
        existing_item = i
        break
      end
    end

    # if item exists -> accumulate
    # else -> create new item
    if existing_item
      existing_item.quantity += quantity
    else
      item = OrderItem.new(
        unit: product.unit,
        quantity: quantity,
        price: product.price,
        name: product.name)
      item.product = product
      @cart.items << item
    end

    # save cart to db
    @cart.save
  end

  def remove_from_cart_remote
    item_id = params[:item_id]

    @item = nil
    @cart.items.each do |i|
      if i.id.to_s == item_id
        @item = i
        break
      end
    end

    if @item
      @cart.items.delete @item
    end

    @cart.save

    render "client/remote/remove_from_cart_remote"
  end

  def cart_detail
    @title = I18n.t("client.cart_detail")
    render "client/cart"
  end

  def pay
    payment = params[:payment].to_i
    
    @cart.name = params[:name]
    @cart.email = params[:email]
    @cart.address = params[:address]
    @cart.phone = params[:phone]
    @cart.payment = payment
    @cart.step = Order::STEP_SENT
    if @user
      @cart.user = @user
    end
    @cart.save

    if payment == Order::PAYMENT_VTC_PAY
      redirect_to get_vtc_pay_url(@cart)
    else
      prepare_cart
      @title = I18n.t("client.pay")
      render "client/payment"
    end
  end

  def profile
    if @user
      @orders = Order.where(step: {'$gt' => Order::STEP_CARTING}, user_id: @user.id)
                  .sort(updated_at: -1).to_a
      @title = I18n.t("client.profile")
      render "client/profile"
    else
      redirect_to client_home_path
    end
  end

  def update_profile
    if @user
      @user.update_attributes(
        name: params[:name],
        email: params[:email],
        address: params[:address],
        phone: params[:phone]
      )
    end
    redirect_to client_home_path
  end

  def login
    session[:fb_id] = params[:fb_id]
    render "client/login"
  end

  def logout
    session[:fb_id] = nil
    redirect_to client_home_path
  end

  def logout_remote
    session[:fb_id] = nil
    render 'client/remote/logout_remote'
  end

  def delete_cart
    session[:cart_order_id] = nil
    if @cart
      @cart.delete
    end
    redirect_to client_home_path
  end

  def order
    @order = Order.where(code: params[:code], user_id: @user.id).first
    if !@order
      redirect_to client_profile_path
    else
      @title = I18n.t "client.order_detail"
      render "client/order_detail"
    end
  end
end