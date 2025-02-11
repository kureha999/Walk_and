class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    @events = current_user.events.order(time: :asc)

    respond_to do |format|
      format.html
      format.json do
        # 日付ごとにイベントをまとめる
        events_by_date = @events.group_by { |event| event.time.to_date }

        render json: events_by_date.map { |date, events|
          {
            id: date.to_s, # 日付を一意のIDとして使用
            title: "⭐️",  # [⭐️] をタイトルとして表示
            start: date.to_s, # 日付を開始日として指定
            url: event_date_path(date: date.to_s)
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
      redirect_to event_date_path(date: @event.time.to_date.to_s), notice: t("controller.event.create")
    else
      render :new, status: :unprocessable_entity, alert: t("controller.event.alert.create")
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to event_date_path(date: @event.time.to_date.to_s), notice: t("controller.event.update")
    else
      render :edit, alert: t("controller.event.alert.update")
    end
  end

  def destroy
    date = @event.time.to_date.to_s # イベントの日付を取得
    if @event.destroy
      respond_to do |format|
        format.html { redirect_to event_date_path(date: date), notice: t("controller.event.destroy") }
        format.json { render json: { status: "success" }, status: :ok }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to event_date_path(date: date), alert: t("controller.event.alert.destroy") }
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
    redirect_to events_path, alert: t("controller.event.alert.authorize") unless @event.user == current_user
  end

  def event_params
    params.require(:event).permit(:title, :event_type, :time, :comment)
  end
end
