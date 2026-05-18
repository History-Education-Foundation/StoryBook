class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:pricing, :about, :contact], raise: false
  skip_before_action :authenticate_user_from_token!, only: [:pricing, :about, :contact], raise: false

  def pricing
  end

  def about
  end

  def contact
  end
end
