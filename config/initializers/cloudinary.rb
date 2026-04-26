Cloudinary.config do |config|
  config.secure = true

  if Rails.application.config.x.cloudinary_enabled && Rails.application.credentials.cloudinary.present?
    config.cloud_name = Rails.application.credentials.cloudinary[:cloud_name]
    config.api_key = Rails.application.credentials.cloudinary[:api_key]
    config.api_secret = Rails.application.credentials.cloudinary[:api_secret]
    config.enhance_image_tag = Rails.application.credentials.cloudinary[:enhance_image_tag]
    config.static_file_support = Rails.application.credentials.cloudinary[:static_file_support]
  else
    # HACK: cloud_nameに空文字列を指定しておけば、
    # Cloudinaryを使用しない開発環境でもcl_image_tagメソッドを使える。
    config.cloud_name = ""
  end
end
