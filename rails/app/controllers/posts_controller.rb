class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = policy_scope(Post).order(created_at: :desc)
  end

  def show
    authorize @post
  end

  def new
    @post = current_user.posts.build
    authorize @post
  end

  def edit
    authorize @post
  end

  def create
    @post = current_user.posts.build(post_params)
    authorize @post

    if @post.save
      redirect_to posts_path, notice: "Post was successfully published! Check it out in the feed below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @post
    if @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: "posts/post", locals: { post: @post }) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @post
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@post) }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :category_id, :author_id, :new_category_name, :new_author_name, :status)
  end
end
