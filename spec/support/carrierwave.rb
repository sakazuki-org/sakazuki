# テストの画像アップロード先を削除する
# 安全のため "_test" で終わるディレクトリのみ削除する
RSpec.configure do |config|
  config.after(:suite) do
    temp_dir = Rails.application.config.x.uploads_dir.to_s
    if Rails.application.config.x.temp_uploads_dir_enabled && temp_dir.end_with?("_test")
      FileUtils.rm_rf(Rails.public_path.join(temp_dir))
    end
  end
end
