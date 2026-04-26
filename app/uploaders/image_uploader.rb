class ImageUploader < CarrierWave::Uploader::Base
  if Rails.application.config.x.cloudinary_enabled
    include Cloudinary::CarrierWave
  else
    include CarrierWave::Vips

    storage :file
  end

  if Rails.application.config.x.cloudinary_enabled
    process(resize_to_limit: [4032, 4032], convert: "avif", quality: "auto", ocr: "adv_ocr:ja")
  end

  version :thumb do
    # HACK: 1:1でスマホで２つ並んでも潰れないサイズ
    process(convert: "webp", resize_to_fill: [600, 600])
  end

  version :large_twitter_card do
    if Rails.application.config.x.cloudinary_enabled
      cloudinary_transformation(
        format: "webp", crop: :thumb, width: 600, height: 300, sign_url: true,
        gravity: :ocr_text
      )
    end
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w[jpg jpeg gif png webp avif]
  end
end
