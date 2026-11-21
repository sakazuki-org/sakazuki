module ApplicationHelper
  # サイトデフォルト設定のメタタグのハッシュを取得する
  #
  # @return [Hash] meta_tagsで利用できるハッシュ
  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      icon: [
        {
          rel: "apple-touch-icon-precomposed",
          sizes: "180x180",
          href: asset_path("apple-touch-icon.avif"),
          type: "image/avif",
        },
        {
          rel: "icon",
          sizes: "32x32",
          href: asset_path("favicon-32x32.avif"),
          type: "image/avif",
        },
      ],
      site: "SAKAZUKI",
      title: "",
      separator: "-",
      reverse: true,
      description: t(".description"),
      og: {
        title: :title,
        url: request.original_url,
        type: "website",
        image: {
          _: image_url("choko.avif"),
          width: 600,
          height: 600,
        },
        description: :description,
      },
      twitter: {
        card: "summary_large_image",
      },
    }
  end

  # rubocop:enable Metrics/MethodLength

  # Google AdSenseのscriptタグを書き出す
  #
  # Production環境かつ環境変数GOOGLE_ADSENSE_CLIENTが設定されてるときのみscriptタグを書き出す。
  # 環境変数GOOGLE_ADSENSE_CLIENTには`ca-pub-0000`形式のパプリッシャーIDをセットする。
  # 設定には.envやSECRETやRails credentialsなどを使う。
  #
  # @return [String] Google AdSense用のscriptタグ
  def adsense_tags
    return unless Rails.application.config.x.adsense_enabled && ENV["GOOGLE_ADSENSE_CLIENT"].present?

    client = ENV.fetch("GOOGLE_ADSENSE_CLIENT", nil)
    src = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=#{client}"
    client ? tag.script(async: "async", src:, crossorigin: "anonymous") : ""
  end
end
