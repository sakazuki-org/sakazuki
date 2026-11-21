# Sake画像に関する機能を提供するモジュール
module SakesPhotos
  extend ActiveSupport::Concern

  # 写真が追加されているかどうかを判定する
  #
  # @param
  # @return [Boolean] 写真が追加されていればtrueを返す
  def store_photos?(sake_params)
    sake_params[:photos].present?
  end

  # 酒に紐づく写真を保存する
  #
  # @param
  # @note sake_paramsから写真を取り出して、酒に紐づく写真として保存する
  def store_photos(sake, sake_params)
    photos = sake_params[:photos]
    photos&.each { |photo| sake.photos.create(image: photo) }
  end

  # 写真が削除されているかどうかを判定する
  #
  # @return [Boolean] 削除対象の写真があればtrueを返す
  def delete_photos?(sake, params)
    sake.photos.any? { |photo| params[photo.checkbox_name].present? }
  end

  # チェックボックスで選択された酒に紐づく写真を削除する
  def delete_photos(sake, params)
    sake.photos.each do |photo|
      photo.destroy! if params[photo.checkbox_name] == "delete"
    end
  end
end
