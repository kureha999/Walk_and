class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    session[:previous_url] = mypage_path
    @posts = current_user.posts.order(created_at: :desc).page(params[:page])
    @is_likes_view = false
  end

  def likes
    session[:previous_url] = mypage_likes_path
    @liked_posts = Post.joins(:likes).where(likes: { user_id: current_user.id }).order("likes.created_at DESC").page(params[:page])
    @is_likes_view = true
    render :show
  end
end
