class LineBotController < ApplicationController
  skip_before_action :verify_authenticity_token

  require "line/bot"

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
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
    user = User.find_by(uid: event["source"]["userId"])
    unless user
      reply_message(event, "ユーザーが見つかりません。アカウントをアプリと連携してください。")
      return
    end

    message = event.message["text"]
    if message.start_with?("[Walk]", "[Food]")
      process_event_registration(event, user, message)
    else
      reply_message(event, "登録形式が正しくありません。\n形式例: [Walk]散歩しました、[Food]ご飯を食べました")
    end
  end

  def process_event_registration(event, user, message)
    begin
      # メッセージ解析
      event_type = message.include?("[Walk]") ? "Walk" : "Food"
      title = message.gsub(/\[Walk\]|\[Food\]/, "").strip
      time = Time.zone.now

      # イベントを保存
      user.events.create!(
        event_type: Event.event_types[event_type],
        title: title,
        time: time
      )

      # ユーザーに成功メッセージを返信
      reply_message(event, "イベントを登録しました！\n種別: #{event_type}\n内容: #{title}")
    rescue StandardError => e
      # エラーメッセージを返信
      reply_message(event, "イベント登録に失敗しました。\nエラー: #{e.message}")
    end
  end

  def reply_message(event, message)
    client.reply_message(event["replyToken"], { type: "text", text: message })
  end
end
