class CivicsController < ApplicationController
  before_action :set_civic_topic, only: %i[ show edit update destroy ]

  # GET /civics or /civics.json
  def index
    @civic_topics = CivicTopic.all
  end

  # GET /civics/1 or /civics/1.json
  def show
    @see_also = Scholar.all.sample(3)
  end

  # GET /civics/new
  def new
    @civic_topic = CivicTopic.new
  end

  # GET /civics/1/edit
  def edit
  end

  # POST /civics or /civics.json
  def create
    @civic_topic = CivicTopic.new(civic_topic_params)

    respond_to do |format|
      if @civic_topic.save
        format.html { redirect_to civic_path(@civic_topic), notice: "Civic topic was successfully created." }
        format.json { render :show, status: :created, location: @civic_topic }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @civic_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /civics/1 or /civics/1.json
  def update
    respond_to do |format|
      if @civic_topic.update(civic_topic_params)
        format.html { redirect_to civic_path(@civic_topic), notice: "Civic topic was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @civic_topic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @civic_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /civics/1 or /civics/1.json
  def destroy
    @civic_topic.destroy!

    respond_to do |format|
      format.html { redirect_to civics_path, notice: "Civic topic was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_civic_topic
      @civic_topic = CivicTopic.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def civic_topic_params
      params.require(:civic_topic).permit(:name, :bio, :tagline, :contributions, :main_ideas, :legacy, :suggested_reading, :main_ideas_heading, :bio_heading, :contributions_heading, :publications, :publications_heading, :suggested_reading_heading, :quote, :quote_author, :criticism, :criticism_heading, :legacy_heading, :image_filename, :image_data, :image_position, :published, :image, :handout_pdf)
    end
end
