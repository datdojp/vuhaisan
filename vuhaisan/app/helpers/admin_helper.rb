module AdminHelper
  def validate_admin
    if session[:admin]
      true
    else
      redirect_to new_admin_session_path
      false
    end
  end

  def prepare_config
    @settei = Settei.first
    if !@settei
      @settei = Settei.create
    end
  end
end