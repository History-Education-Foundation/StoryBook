class CivicsController < ApplicationController
  before_action :set_civic_topic, only: %i[ show edit update destroy ]

  # GET /civics or /civics.json
  def index
    allowed_names = [
      "Andrew Yang",
      "Bernie Sanders",
      "New Deal",
      "U.S. Intervention abroad",
      "Israel and 9/11",
      "James Lindsay",
      "Intimidation during the Iraq War",
      "American Civics Renewal Act",
      "Lobbying",
      "Potential context for Utah’s 1st Congressional District (CD1) Race"
    ]
    
    @grouped_topics = CivicTopic.where(name: allowed_names).group_by { |t| t.subject.presence || "Political Figures & Policies" }
    
    # Sort the allowed topics according to the order in allowed_names for the "Political Figures & Policies" section
    if @grouped_topics["Political Figures & Policies"]
      @grouped_topics["Political Figures & Policies"] = @grouped_topics["Political Figures & Policies"].sort_by { |t| allowed_names.index(t.name) || 99 }
    end

    @subject_order = [
      "Political Figures & Policies",
      "U.S. History",
      "World History",
      "World Geography",
      "Financial Literacy",
      "Psychology",
      "Digital Literacy",
      "Student Leaders"
    ]
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
