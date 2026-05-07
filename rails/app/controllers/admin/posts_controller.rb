class Admin::PostsController < Admin::BaseController
  layout "application"
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    @posts = Post.order(created_at: :desc)
    @categories = Category.all
    @authors = Author.all
    @post = Post.new
    @category = Category.new
    @author = Author.new
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.turbo_stream
        format.html { redirect_to admin_posts_path, notice: "Post was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_post_form", partial: "admin/posts/form", locals: { post: @post }), status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream
        format.html { redirect_to admin_posts_path, notice: "Post was successfully updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: "admin/posts/form", locals: { post: @post }), status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_posts_path, notice: "Post was successfully destroyed.", status: :see_other }
    end
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :body, :category_id, :author_id)
    end
end
