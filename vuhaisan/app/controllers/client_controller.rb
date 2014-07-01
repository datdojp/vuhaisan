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
    :confirm,
    :order,
    :info
  ]
  before_filter :prepare_selected_categories, only: [:home]
  before_filter :prepare_profile, only: [
    :profile,
    :update_profile,
    :cart_detail,
    :confirm,
    :order
  ]
  before_filter :prepare_product_custom_fields, only: [:add_to_cart, :add_to_cart_remote]

  layout "client"

  def prepare
    prepare_categories
    prepare_cart
  end

  def prepare_product_custom_fields
    @custom_field_values = []
    params.keys.each do |k|
      if /^_custom_field_value_\d+$/.match(k)
        @custom_field_values << params[k]
      end
    end
  end

  def home
    @keyword = params[:keyword]
    @keyword.strip! if @keyword
    if @keyword && @keyword.length > 0
      criteria = Product.general_search @keyword
      @category_id = nil
    else
      criteria = Product.where(category_id: @category_id)
    end

    if request.method == "POST" && @keyword && @keyword.length > 0
      __log_search(@keyword, criteria.length)
      redirect_to client_home_path(keyword: @keyword)
      return
    end

    if @category_id
      @category = Category.where(id: @category_id).first

      tag_tree_path = params[:tag_tree_path]
      tag_tree_path.strip! if tag_tree_path
      if  tag_tree_path &&
          tag_tree_path.length > 0 &&
          @category &&
          @category.has_tag_tree?
        splitted = tag_tree_path.split(',')
        @tag_tree_path = []
        splitted.each do |t|
          next if !t || t.length == 0
          @tag_tree_path << t
        end
        current_node = @category.tag_tree
        @tag_tree_path.each do |t|
          next_child = nil
          current_node['children'].each do |child|
            if child['name'] == t
              next_child = child
              break
            end
          end
          if next_child
            current_node = next_child
          else
            break
          end
        end
        if current_node
          criteria = criteria.where(id: { '$in' => current_node['pids'] })
        end
      end
    end

    # do not show hidden product (product whose category is hidden)
    if !params[:ignore_hidden]
      criteria = criteria.where(hidden: false)
    end

    # sort by updated_at
    criteria = criteria.order_by([[:updated_at, :desc]])

    @products = criteria.page(params[:page]).per(10)

    @title = I18n.t("client.home")
    render "client/home"
  end

  def __log_search(keyword, n_results)
    if keyword && keyword.length > 0
      kensaku = Kensaku.where(keyword: keyword).first
      if kensaku
        kensaku.n_searches = kensaku.n_searches + 1
        kensaku.last_n_results = n_results
        kensaku.save
      else
        Kensaku.create(
          keyword: keyword,
          n_searches: 1,
          last_n_results: n_results)
      end
    end
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
    @product_id = params[:product_id]
    render "client/remote/add_to_cart_remote", layout: nil
  end

  def common_add_to_cart
    product = Product.where(id: params[:product_id]).first
    quantity = params[:quantity].to_i

    # check if product is already added
    existing_item = nil
    @cart.items.each do |i|
      if  i.product_id == product.id &&
          i.unit == product.unit &&
          i.price == product.price &&
          i.custom_field_values == @custom_field_values
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
        custom_field_values: @custom_field_values)
      if @custom_field_values.length > 0
        item.name = "#{product.name} - #{item.custom_field_values_as_text}"
      else
        item.name = product.name
      end
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

  def confirm
    if @cart && @cart.sum_quantity > 0
      payment = params[:payment].to_i
      
      @cart.name = params[:name]
      @cart.email = params[:email]
      @cart.phone = params[:phone]
      @cart.payment = payment
      @cart.step = Order::STEP_SENT
      if @user
        @cart.user = @user
      end

      # generate address
      arr = [params[:address][:detail]]
      arr << params[:address][:district] if params[:address][:district]
      arr << params[:address][:province]
      @cart.address = arr.join(", ")

      # generate ship cost
      location_data_lv1 = LOCATION_DATA[params[:address][:province]]
      if location_data_lv1.is_a?(Integer)
        @cart.ship_cost = location_data_lv1
      elsif location_data_lv1.is_a?(Hash)
        @cart.ship_cost = location_data_lv1[params[:address][:district]]
      end

      # notify user by email
      if @cart.should_mail?
        UserMailer.order_changed_email(@cart).deliver
      end

      @cart.save

      if payment == Order::PAYMENT_VTC_PAY
        redirect_to get_vtc_pay_url(@cart)
      else
        prepare_cart
        @title = I18n.t("client.message")
        if payment == Order::PAYMENT_AT_DELIVERIED
          @message = I18n.t("client.confirm_success_at_delivery")
        elsif payment == Order::PAYMENT_BANK_TRANSFER
          @message = I18n.t("client.confirm_success_bank_transfer")
        end
        render "client/message"
      end
    else
      redirect_to client_cart_detail_path
    end
  end

  def profile
    if @user
      @order_keyword = params[:order_keyword]
      @order_keyword.strip! if @order_keyword
      if @order_keyword && @order_keyword.length > 0
        criteria = Order.general_search @order_keyword
      else
        criteria = Order.all
      end

      @orders = criteria.where(step: {'$gt' => Order::STEP_CARTING})
                  .where(user_id: @user.id)
                  .order_by([[:updated_at, :desc]])
                  .page(params[:page]).per(10)
      @title = I18n.t("client.profile")
      render "client/profile"
    else
      @title = I18n.t("client.message")
      @error = I18n.t 'client.err_user_not_logged_in'
      render "client/message"
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

  def login_remote
    session[:fb_id] = params[:fb_id]
    render "client/remote/login_remote"
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
    @order = Order.where(code: params[:code]).first

    if @order
      if @order.user
        if !@user
          __order_not_logged_in
          return
        end
        if @user.id != @order.user_id
          __order_not_found
          return
        end
      end
    else
      __order_not_found
      return
    end

    @title = I18n.t "client.order_detail"
    render "client/order_detail"
  end

  def __order_not_found
    @title = I18n.t("client.message")
    @error = I18n.t 'client.err_order_not_found'
    render "client/message"
  end

  def __order_not_logged_in
    @title = I18n.t("client.message")
    @error = I18n.t 'client.err_user_not_logged_in'
    render "client/message"
  end

  def info
    @title = I18n.t('client.info')
    @settei = Settei.first
    if !@settei
      redirect_to client_home_path
    else
      render 'client/info'
    end
  end
end