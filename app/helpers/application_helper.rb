module ApplicationHelper
  def default_meta_tags
    {
      site: "WALK&",
      title: "お散歩&餌を楽しく記録へ",
      reverse: true,
      charset: "utf-8",
      description: "お散歩&餌の時間を簡単に記録し、写真を共有しながらみんなで楽しく愛犬を共有できるアプリです。",
      keywords: "犬,散歩,餌,写真,記録,共有,愛犬,散歩",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("walk_top.jpg"), # 配置するパスやファイル名によって変更すること
        local: "ja-JP"
      },
      # Twitter用の設定を個別で設定する
      twitter: {
        card: "summary_large_image", # Twitterで表示する場合は大きいカードにする
        site: "@", # アプリの公式Twitterアカウントがあれば、アカウント名を書く
        image: image_url("favicon.ico") # 配置するパスやファイル名によって変更すること
      }
    }
  end
end
