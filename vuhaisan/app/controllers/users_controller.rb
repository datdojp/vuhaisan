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
    @keyword = params[:keyword]
    if @keyword
      criteria = User.general_search @keyword
    else
      criteria = User.all
    end
    
    @users = criteria.page(params[:page]).per(10)

    @title = I18n.t "admin.user_list"
    render "admin/user/index"
  end
end