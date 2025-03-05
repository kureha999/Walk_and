class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    @posts = Post.includes(:user).order(created_at: :desc).page(params[:page])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    Rails.logger.debug "Post params: #{post_params.inspect}"
    Rails.logger.debug "Creating post with params: #{post_params.inspect}"


    image_temp = @post.image
    @post.image = nil

    if @post.save

      @post.update(image: image_temp)
      redirect_to posts_path, notice: t("controller.post.create")
    else
      flash.now[:alert] = t("controller.post.alert.create")
      render :new
    end
  end

  def show
    session[:previous_url] = params[:previous_url] if params[:previous_url].present?
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post), notice: t("controller.post.update")
    else
      flash.now[:alert] = t("controller.post.alert.update")
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to mypage_path, notice: t("controller.post.destroy")
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to posts_path, alert: t("controller.post.alert.authorize") unless @post.user == current_user
  end

  def post_params
    params.require(:post).permit(:body, :image, :image_cache)
  end
end
