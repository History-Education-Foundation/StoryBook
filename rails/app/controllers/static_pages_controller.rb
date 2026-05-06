class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:pricing, :about], raise: false
  skip_before_action :authenticate_user_from_token!, only: [:pricing, :about], raise: false

  def pricing
  end

  def about
  end
end
