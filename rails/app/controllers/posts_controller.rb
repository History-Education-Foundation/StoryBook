class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @posts = Post.order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      respond_to do |format|
        format.html { redirect_to posts_path, notice: "Post was successfully created." }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.prepend("posts-grid", partial: "posts/post", locals: { post: @post }),
            turbo_stream.update("new_post_form", "") # Close the form if it was in a frame
          ]
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :category_id, :author_id)
  end
end
