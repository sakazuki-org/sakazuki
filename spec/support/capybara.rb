require "capybara-playwright-driver"
require "capybara/rails"
require "capybara/rspec"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :firefox, headless: true)
end

Capybara.configure do |config|
  # driver設定: https://www.rubydoc.info/gems/capybara/Capybara#configure-class_method
  config.default_driver = :rack_test
  config.javascript_driver = :playwright

  # "data-testid"をCapybaraのclick_linkなどで使えるように、Optional attributeに登録する
  config.test_id = "data-testid"

  # Capybaraのアサーションが失敗したときに自動再試行する時間
  # JS処理が間に合わないなどフレーキーなテストへの対応するため少し長くする
  config.default_max_wait_time = 5

  # テスト失敗時にテストリトライを行うまでの時間
  config.default_retry_interval = 0.25
end

RSpec.configure do |config|
  config.before(:each, type: :system) do |example|
    # context/describe/itの`js: true`でdriverを切り替える
    driver = example.metadata[:js] ? Capybara.javascript_driver : Capybara.default_driver
    driven_by(driver)
  end
end

# Capybaraのカスタムセレクタ
# find(:test_id, "email")でfind("[data-testid='email']")と同じく、data-testidが指定値のタグを取得できる
# 参考: https://speakerdeck.com/yasaichi/tokyurubykaigi12
Capybara.add_selector(:test_id) do
  css { |val| %([data-testid="#{val}"]) }
end

# ページ遷移を待つ
#
# JS実行driverを使うと、テスト処理にページ遷移が追いつかずテストが落ちることがある。
# このメソッドでページ遷移を待つことができる。
# 対象ページにはdata-testidに自身のパスを持つことを想定している。
#
# @example index.htmlの場合
#   wait_for_page(sakes_path)
#
# @param page_path [String] ページのパス
def wait_for_page(page_path)
  find(:test_id, page_path, visible: false)
end

# alertが表示されるまで待つ
#
# ユーザーが現在いるページにリダイレクトされたとき、何らかのアラートが表示されるまで待つ。
def wait_for_alert
  find(:test_id, "flash_message")
end

# 酒のshowページのパスから、そのページで表示している酒オブジェクトを取得する
#
# @param url_path [String] "/sakes/1"のようなshowページのパス
# @return [Sake] 酒オブジェクト
def sake_from_show_path(url_path)
  path_pattern = %r{^/sakes/(\d+)$}
  result = path_pattern.match(url_path)
  result && Sake.find(result[1])
end
