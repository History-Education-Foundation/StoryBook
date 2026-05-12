class ControversiesController < ApplicationController
  def index
    @controversies = Controversy.all
  end

  def show
    @controversy = Controversy.find(params[:id])
    @scholars = Scholar.all.sample(3)
  end
end
