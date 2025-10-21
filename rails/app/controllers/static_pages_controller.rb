class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:pricing, :about]
  skip_before_action :authenticate_user_from_token!, only: [:pricing, :about]

  def pricing
  end

  def about
  end
end
