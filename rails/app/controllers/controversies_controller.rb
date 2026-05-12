class ControversiesController < ApplicationController
  def index
    @controversies = Controversy.all
  end

  def show
    @controversy = Controversy.find(params[:id])
  end
end
