class ProductsController < ApplicationController

  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :load_categories, only: [:index, :new, :edit]
  before_filter :save_image, only: [:create, :update]
  before_filter :prepare_config

  def set_tab_index
    @tab = 0
  end

  def load_categories
    @categories = Category.all.to_a
  end

  def save_image
    data = params[:product][:image]
    if data
      filename = SecureRandom.hex
      File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
        file.write(data.read)
      end
      params[:product][:image] = filename
    end
  end

  def index
    @keyword = params[:keyword]
    if @keyword && @keyword.length > 0
      criteria = Product.general_search @keyword
    else
      criteria = Product.all
    end

    @products = criteria.page(params[:page]).per(10)
    @title = I18n.t "admin.product_list"
    render "admin/product/index"
  end

  def new
    @title = I18n.t "admin.create_product"
    @product = Product.new
    render "admin/product/new"
  end

  def create
    Product.create params[:product]
    redirect_to products_path
  end

  def edit
    @product = Product.where(id: params[:id]).first
    if !@product
      redirect_to products_path
    else
      @title = I18n.t "admin.edit_product"
      render "admin/product/edit"
    end
  end

  def update
    @product = Product.where(id: params[:id]).first
    if @product
      if params[:product][:image]
        @product.delete_image
      end
      @product.update_attributes params[:product]
    end
    redirect_to products_path
  end

  def destroy
    product = Product.where(id: params[:id]).first
    if product
      product.delete_image
      product.delete
    end
    redirect_to products_path
  end
end