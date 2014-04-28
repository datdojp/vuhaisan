class SetteiController < ApplicationController
  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :prepare_config

  def set_tab_index
    @tab = 2
  end

  def edit
    @title = I18n.t "admin.settei"
    render "admin/settei/edit"
  end

  def update
    @settei.update_attributes params[:settei]
    redirect_to products_path
  end
end