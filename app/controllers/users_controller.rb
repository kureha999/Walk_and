class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @posts = current_user.posts.order(created_at: :desc).page(params[:page])
  end
end
