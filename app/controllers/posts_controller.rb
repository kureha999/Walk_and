class PostsController < ApplicationController
  # ログイン中のユーザーのみに投稿、編集、削除を許可
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
    if @post.save
      redirect_to posts_path, notice: "投稿が作成されました。"
    else
      flash.now[:alert] = "投稿に失敗しました。"
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post), notice: "投稿が更新されました。"
    else
      flash.now[:alert] = "投稿の更新に失敗しました。"
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to mypage_path, notice: "投稿を削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to posts_path, alert: "この投稿を編集する権限がありません。" unless @post.user == current_user
  end

  def post_params
    params.require(:post).permit(:body, :image)
  end
end
