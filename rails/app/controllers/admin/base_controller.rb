class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You do not have permission to access the Blog Dashboard. Please log in as an administrator."
    end
  end
end
