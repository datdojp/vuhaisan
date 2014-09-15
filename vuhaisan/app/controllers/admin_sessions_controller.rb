class AdminSessionsController < ApplicationController

  ADMIN_USERNAME = "khuonganh"
  ADMIN_PASSWORD = "khuonganhxinhdep"

  def new
    render "admin/session/new"
  end

  def create
    if ADMIN_USERNAME != params[:username] || ADMIN_PASSWORD != params[:pass]
      render "admin/session/new"
    else
      session[:admin] = true
      redirect_to products_path
    end
  end

  def logout
    session[:admin] = false
    redirect_to new_admin_session_path
  end
end