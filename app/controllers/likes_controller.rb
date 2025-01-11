class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    current_user.likes.create(post: @post)
    redirect_back fallback_location: post_path(@post)
  end

  def destroy
    like = current_user.likes.find(params[:id])
    @post = like.post
    like.destroy
    redirect_back fallback_location: post_path(@post)
  end
end
