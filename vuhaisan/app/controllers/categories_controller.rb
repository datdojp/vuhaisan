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
    @categories = Category.all.order_by([[:no, :asc]]).to_a
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
    cat = Category.where(id: params[:id]).first
    if cat
      cat.delete
      Category.where(no: {"$gt" => cat.no}).to_a.each do |c|
        c.no = c.no - 1
        c.save
      end
    end

    # delete related products
    products = Product.where(category_id: params[:id]).to_a
    products.each do |p|
      p.delete
    end

    redirect_to categories_path
  end

  def categories_index_update
    id = params[:id]
    action = params[:update].to_s
    cat = Category.where(id: id).first
    if cat
      if action == 'up' && cat.no > 0
        other_cat = Category.where(no: cat.no - 1).first
        t = cat.no
        cat.no = other_cat.no
        other_cat.no = t
      elsif action == 'down' && cat.no < Category.count - 1
        other_cat = Category.where(no: cat.no + 1).first
        t = cat.no
        cat.no = other_cat.no
        other_cat.no = t
      elsif action == 'toggle_hidden'
        cat.hidden = !cat.hidden
      end
      cat.save
      other_cat.save if other_cat
    end
    redirect_to categories_path
  end
end