module ClientHelper
  def prepare_categories
    @categories = Category.get_client_categories_criteria.to_a
  end

  def prepare_selected_categories
    @category_id =
      params[:category_id] ||
      Category.get_client_categories_criteria.only(:id).first.id.to_s
  end

  def prepare_cart
    if session[:cart_order_id]
      @cart = Order.where(id: session[:cart_order_id], step: Order::STEP_CARTING).first
    end
    if !@cart
      @cart = Order.create
      session[:cart_order_id] = @cart.id.to_s
    end
  end

  def prepare_profile
    fb_id = session[:fb_id]
    if fb_id
      @user = User.where(fb_id: fb_id).first
      if !@user
        @user = User.create(fb_id: fb_id)
      end
    end
  end
end
