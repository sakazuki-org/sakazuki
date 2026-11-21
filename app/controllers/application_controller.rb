class ApplicationController < ActionController::Base
  after_action :store_location

  def signed_in_user
    return if user_signed_in?

    # 未ログインユーザーが酒作成・編集しようとしたときにパスを保存する
    store_location
    redirect_to(new_user_session_path, status: :see_other, alert: t("devise.failure.unauthenticated"))
  end

  # サインイン時にユーザーが元いたパスへ戻れるようにするため、
  # deviseのstore_location_forを使ってユーザーが居たパスを保存する
  def store_location
    store_location_for(:user, request.fullpath) if storable_location?
  end

  private

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
