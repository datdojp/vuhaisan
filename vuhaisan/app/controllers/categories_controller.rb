class CategoriesController < ApplicationController
  
  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :prepare_config

  def set_tab_index
    @tab = 1
  end

  def index
    @title = I18n.t "admin.category_list"
    @categories = Category.all.to_a
    render "admin/category/index"
  end

  def new
    @title = I18n.t "admin.create_category"
    @category = Category.new
    render "admin/category/new"
  end

  def create
    @category = Category.new params[:category]

    if !@category.save
      @title = I18n.t "admin.create_category"
      @error = I18n.t "admin.err_category_name_exist"
      render "admin/category/new"
    else
      redirect_to categories_path
    end
  end

  def edit
    @title = I18n.t "admin.edit_category"
    @category = Category.where(id: params[:id]).first
    render "admin/category/edit"
  end

  def update
    @category = Category.where(id: params[:id]).first
    if !@category
      redirect_to categories_path
    elsif !@category.update_attributes(params[:category])
      @title = I18n.t "admin.edit_category"
      @error = I18n.t "admin.err_category_name_exist"
      render "admin/category/edit"
    else
      redirect_to categories_path
    end
  end

  def destroy
    # delete category
    Category.where(id: params[:id]).delete

    # delete related products
    products = Product.where(category_id: params[:id]).all
    if products && products.length > 0
      products.each do |p|
        p.delete_image
        p.delete
      end
    end

    redirect_to categories_path
  end
end