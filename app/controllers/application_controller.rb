class ApplicationController < ActionController::Base
  after_action :store_location
  around_action :switch_api_locale, if: -> { request.format.json? }

  # ブラウザはAuthorizationヘッダーを自動で付けないので、トークン認証のリクエストはCSRFの対象にならない。
  # 「JSONなら外す」にすると、ログイン中のブラウザに罠ページからJSONをPOSTさせる攻撃が通る。
  skip_forgery_protection if: :api_token_authenticated?

  def signed_in_user
    return if user_signed_in?
    return head(:unauthorized) if request.format.json?

    # 未ログインユーザーが酒作成・編集しようとしたときにパスを保存する
    store_location
    redirect_to(new_user_session_path, status: :see_other, alert: t("devise.failure.unauthenticated"))
  end

  # JSON APIのトークンでも通すsigned_in_user
  def signed_in_user_or_api_token
    signed_in_user unless api_token_authenticated?
  end

  # サインイン時にユーザーが元いたパスへ戻れるようにするため、
  # deviseのstore_location_forを使ってユーザーが居たパスを保存する
  def store_location
    store_location_for(:user, request.fullpath) if storable_location?
  end

  private

  # @return [Boolean] AuthorizationヘッダーのBearerトークンが環境変数API_TOKENと一致すればtrue
  def api_token_authenticated?
    expected = ENV["API_TOKEN"].presence
    # 消すとAPI_TOKENが未設定の環境でsecure_compareにnilが渡り、401でなく500になる
    return false unless expected

    authenticated = authenticate_with_http_token { |token, _options| ActiveSupport::SecurityUtils.secure_compare(token, expected) }
    authenticated || false
  end

  # JSON APIのエラーメッセージを、Accept-Languageで選んだロケールで返す
  def switch_api_locale(&)
    I18n.with_locale(api_locale, &)
  end

  # shortcut: q値を見ずに、Accept-Languageに並んだ順で最初に対応している言語を選ぶ。
  # q値で順番を入れ替えるクライアントが出てきたら、q値で並べ替える。
  #
  # @return [Symbol] ロケール。対応している言語がなければ既定のロケール
  def api_locale
    tags = request.headers["Accept-Language"].to_s.split(",").map { |tag| tag[/\A\s*([a-z]{2})/i, 1]&.downcase&.to_sym }
    tags.find { |tag| I18n.available_locales.include?(tag) } || I18n.default_locale
  end

  # 下記すべての条件を満たすとき、ユーザーが居たパスを保存してよいと判定する。
  # - リクエストがGETメソッドである。
  # - Ajaxリクエストではない。
  # - JSONリクエストではない。
  # - ユーザー認証ページへのパスではない。
  #   （リダイレクトループが発生するのを避けるため）
  # 参考: https://github.com/heartcombo/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  # @return [Boolean] ユーザーが居たパスを保存していいときにtrueを返す。
  def storable_location?
    request.get? && !request.xhr? && !request.format.json? && !request.path.match?("/users/.*")
  end
end
