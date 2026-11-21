# == Schema Information
#
# Table name: photos
#
#  id         :bigint           not null, primary key
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sake_id    :integer
#
class Photo < ApplicationRecord
  belongs_to :sake
  mount_uploader :image, ImageUploader

  def checkbox_name
    "photo_delete_#{id}"
  end

  # cl_image_tag/cl_image_pathで使える画像への参照を返す
  #
  # production環境では`full_public_id`を返す
  # それ以外では画像ファイルのパスを返す
  # @note production環境以外ではcl_image_tagにパスを渡すことで`angle: ignore`のような変換オプションを無視する
  # @return [String] 画像への参照
  def cl_reference
    Rails.application.config.x.cloudinary_enabled ? image.full_public_id : image.url
  end
end
