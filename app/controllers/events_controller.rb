class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    @events = current_user.events.order(time: :asc)

    respond_to do |format|
      format.html
      format.json do
        render json: @events.map { |event|
          {
            id: event.id,
            title: event.title,
            start: event.time.in_time_zone("Asia/Tokyo").iso8601, # タイムゾーンを変換して送信
            url: event_path(event)
          }
        }
      end
    end
  end


  def new
    @event = current_user.events.build(time: params[:date]) # URLのdateパラメータを利用
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      redirect_to events_path, notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to events_path, notice: "Event updated successfully."
    else
      render :edit
    end
  end

  def destroy
    if @event.destroy
      render json: { status: "success" }, status: :ok
    else
      render json: { status: "error" }, status: :unprocessable_entity
    end
  end

  def date_details
    @date = params[:date]
    @events = current_user.events
                          .where("time::timestamp::date = ?", @date) # timeをtimestamp型にキャストし、その後dateにキャスト
                          .order(time: :asc) # 時間順に並べる
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_user!
    redirect_to events_path, alert: "You are not authorized to perform this action." unless @event.user == current_user
  end

  def event_params
    params.require(:event).permit(:title, :event_type, :time, :comment)
  end
end
