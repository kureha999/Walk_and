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

  def show
    @event = Event.find(params[:id])  # イベントIDをもとにイベントを取得
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
      respond_to do |format|
        format.html { redirect_to events_path, notice: "Event deleted successfully." }
        format.json { render json: { status: "success" }, status: :ok }
        format.turbo_stream # Turbo Streams に対応
      end
    else
      respond_to do |format|
        format.html { redirect_to events_path, alert: "Failed to delete event." }
        format.json { render json: { status: "error" }, status: :unprocessable_entity }
      end
    end
  end

  def date_details
    @date = params[:date]

    # タイムゾーンの設定を確認
    timezone = ActiveSupport::TimeZone["Asia/Tokyo"]

    # @dateをタイムゾーン付きのDateTimeオブジェクトに変換
    parsed_date = timezone.parse(@date)

    unless parsed_date
      @events = []
      return
    end

    # 範囲を指定してイベントを取得
    start_of_day = parsed_date.beginning_of_day
    end_of_day = parsed_date.end_of_day

    @events = current_user.events
                          .where(time: start_of_day..end_of_day) # UTC時間帯で比較
                          .order(time: :asc)
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
