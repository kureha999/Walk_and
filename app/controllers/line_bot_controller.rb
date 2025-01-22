class LineBotController < ApplicationController
  skip_before_action :verify_authenticity_token

  require "line/bot"

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end
  end

  def callback
    body = request.body.read

    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        handle_message(event)
      end
    end

    head :ok
  end

  private

  def handle_message(event)
    user_id = event["source"]["userId"]
    user = User.find_by(uid: user_id)

    unless user
      reply_message(event, t("controller.line_bot.not_found"))
      return
    end

    message = event.message["text"]
    user_state = user.user_state

    # ユーザー状態確認
    if user_state
      process_event_registration(event, user, user_state.state, message)
      user_state.destroy # 状態リセット
    else
      case message
      when /餌をあげた時間を記録/
        user.create_user_state!(state: "Food")
        reply_message(event, t("controller.line_bot.please_send_food"))
      when /お散歩を記録/
        user.create_user_state!(state: "Walk")
        reply_message(event, t("controller.line_bot.please_send_walk"))
      else
        reply_message(event, t("controller.line_bot.replay"))
      end
    end
  end

  def process_event_registration(event, user, event_type, title)
    begin
      time = Time.zone.now

      # イベントを保存
      user.events.create!(
        event_type: Event.event_types[event_type],
        title: title.strip,
        time: time
      )

      # ユーザーに成功メッセージを返信
      reply_message(event, t("controller.line_bot.success"))
    rescue StandardError => e
      # エラーメッセージを返信
      reply_message(event, t("controller.line_bot.error"))
    end
  end

  def reply_message(event, message)
    client.reply_message(event["replyToken"], { type: "text", text: message })
  end
end
