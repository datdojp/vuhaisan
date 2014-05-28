class ProductsController < ApplicationController

  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :load_categories, only: [:index, :new, :edit]
  before_filter :save_image, only: [:create, :update]
  before_filter :prepare_config
  before_filter :make_custom_fields, only: [:create, :update]
  before_filter :make_tags, only: [:create, :update]

  def set_tab_index
    @tab = 0
  end

  def load_categories
    @categories = Category.all.to_a
  end

  def save_image
    params[:product][:images] = []
    params.keys.each do |k|
      if /^_image_\d+$/.match k
        data = params[k]
      end
      if data && data.is_a?(ActionDispatch::Http::UploadedFile)
        filename = SecureRandom.hex
        File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
          file.write(data.read)
        end
        params[:product][:images] << "/uploads/#{filename}"
      elsif data && data.is_a?(String)
        data.strip!
        if Product.is_remote_image?(data) || Product.is_local_image?(data)
          params[:product][:images] << data
        end
      end
    end
  end

  def make_custom_fields
    custom_fields = {}
    params.keys.each do |k|
      if /^_custom_field_name_\d+$/.match(k)
        id = k.scan(/.*(\d+)/).first.first
        name = params[k].to_sym
        options = params["_custom_field_options_#{id}".to_sym].split(",")
        options.each {|o| o.strip! }
        custom_fields[name] = options
      end
    end
    params[:product][:custom_fields] = custom_fields
  end

  def make_tags
    tags = []
    params.keys.each do |k|
      if /^_tag_\d+$/.match(k)
        t = params[k].strip
        tags << t  if t && t.length > 0
      end
    end
    params[:product][:tags] = tags
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
      if @product.has_image?
        removed = []
        @product.images.each do |i|
          if  Product.is_local_image?(i) && !params[:product][:images].find_index(i)
            Product.delete_image i
          end
        end
      end
      @product.update_attributes params[:product]
    end
    redirect_to products_path
  end

  def destroy
    product = Product.where(id: params[:id]).first
    if product
      product.delete
    end
    redirect_to products_path
  end
end