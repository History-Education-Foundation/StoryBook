class Admin::AuthorsController < Admin::BaseController
  layout "application"
  before_action :set_author, only: %i[ show edit update destroy ]

  def index
    @authors = Author.all
  end

  def show
  end

  def new
    @author = Author.new
  end

  def edit
  end

  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.turbo_stream
        format.html { redirect_to admin_authors_path, notice: "Author was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_author_form", partial: "admin/authors/form", locals: { author: @author }), status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @author.update(author_params)
        format.turbo_stream
        format.html { redirect_to admin_authors_path, notice: "Author was successfully updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@author, partial: "admin/authors/form", locals: { author: @author }), status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @author.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_authors_path, notice: "Author was successfully destroyed.", status: :see_other }
    end
  end

  private
    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :bio)
    end
end
