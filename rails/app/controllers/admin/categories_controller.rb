class Admin::CategoriesController < Admin::BaseController
  layout "application"
  before_action :set_category, only: %i[ show edit update destroy ]

  def index
    @categories = Category.all
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.turbo_stream
        format.html { redirect_to admin_categories_path, notice: "Category was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_category_form", partial: "admin/categories/form", locals: { category: @category }), status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.turbo_stream
        format.html { redirect_to admin_categories_path, notice: "Category was successfully updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@category, partial: "admin/categories/form", locals: { category: @category }), status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_categories_path, notice: "Category was successfully destroyed.", status: :see_other }
    end
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
end
