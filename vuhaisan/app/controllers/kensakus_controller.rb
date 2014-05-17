class KensakusController < ApplicationController
  include AdminHelper

  layout "admin"

  before_filter :validate_admin
  before_filter :set_tab_index
  before_filter :prepare_config

  FILTER_NO_RESULT = "no_result"
  FILTER_HAS_RESULT = "has_result"

  def set_tab_index
    @tab = 5
  end

  def index
    @filter = params[:filter]
    if @filter == FILTER_NO_RESULT
      criteria = Kensaku.where(last_n_results: 0)
    elsif @filter == FILTER_HAS_RESULT
      criteria = Kensaku.where(last_n_results: {"$gt" => 0})
    else
      criteria = Kensaku.all
    end
    @kensakus = criteria.order_by([[:updated_at, :desc]]).page(params[:page]).per(10)
    @title = I18n.t 'admin.kensaku'
    render 'admin/kensaku/index'
  end
end