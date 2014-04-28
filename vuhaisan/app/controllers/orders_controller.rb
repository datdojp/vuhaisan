class OrdersController < ApplicationController

  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :prepare_config

  def set_tab_index
  	@tab = 4
  end

  def index
  	@keyword = params[:keyword]
    @from = params[:from]
    @to = params[:to]
    @timezone = params[:timezone]
  	if @keyword
  	  criteria = Order.general_search @keyword
  	else
  	  criteria = Order.all
  	end
    criteria = criteria.where(step: {'$gt' => Order::STEP_CARTING})
    if @from && @from.length > 0
      criteria = criteria.where(:updated_at.gte => Time.parse("#{@from} 00:00:00 #{@timezone}"))
    end
    if @to && @to.length > 0
      criteria = criteria.where(:updated_at.lte => Time.parse("#{@to} 23:59:59 #{@timezone}"))
    end
  	
  	@orders = criteria.order_by([[:updated_at, :desc]]).page(params[:page]).per(10)
  	@title = I18n.t "admin.order_list"
  	render "admin/order/index"
  end

  def edit
    id = params[:id]
    @order = Order.where(id: id).first
    if !@order
      redirect_to orders_path
    else
      @title = "#{I18n.t("admin.order_detail")} #{@order.code}"
      render "admin/order/edit"
    end
  end

  def update
    @order = Order.where(id: params[:id]).first
    if @order
      @order.update_attributes params[:order]
    end
    redirect_to orders_path
  end
end