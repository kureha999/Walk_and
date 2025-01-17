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

  # ユーザー状態を保存する簡易的なデータ構造（本番ではDBを使用するべき）
  @@user_states = {}

  def handle_message(event)
    user_id = event["source"]["userId"]
    user = User.find_by(uid: user_id)

    unless user
      reply_message(event, "ユーザーが見つかりません。\nアカウントをアプリと連携してください。")
      return
    end

    message = event.message["text"]

    # ユーザー状態確認
    if @@user_states[user_id]
      process_event_registration(event, user, @@user_states[user_id], message)
      @@user_states.delete(user_id) # 状態リセット
    else
      case message
      when /餌をあげた時間を記録/
        @@user_states[user_id] = "Food"
        reply_message(event, "タイトルを送信してください🍴")
      when /お散歩を記録/
        @@user_states[user_id] = "Walk"
        reply_message(event, "タイトルを送信してください🦮")
      else
        reply_message(event, "登録形式が正しくありません。\n'餌をあげた時間を記録' や 'お散歩を記録' と送信してください。")
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
      reply_message(event, "イベントを登録しました😊\n種別: #{event_type}\nタイトル: #{title.strip}")
    rescue StandardError => e
      # エラーメッセージを返信
      reply_message(event, "イベント登録に失敗しました。\nエラー: #{e.message}")
    end
  end

  def reply_message(event, message)
    client.reply_message(event["replyToken"], { type: "text", text: message })
  end
end
