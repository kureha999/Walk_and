class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @posts = current_user.posts.order(created_at: :desc).page(params[:page])
  end

  def likes
    @liked_posts = Post.joins(:likes).where(likes: { user_id: current_user.id }).order("likes.created_at DESC").page(params[:page])
    render :show
  end
end
