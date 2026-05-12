class ConceptsController < ApplicationController
  def index
    @concepts = Concept.all
  end

  def show
    @concept = Concept.find(params[:id])
    @scholars = Scholar.all.sample(3)
  end
end
