class UsersController < ApplicationController
  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :prepare_config

  def set_tab_index
    @tab = 3
  end

  def index
    @title = I18n.t "admin.user_list"
    @users = User.all.page(params[:page]).per(10)
    render "admin/user/index"
  end
end