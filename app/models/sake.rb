# == Schema Information
#
# Table name: sakes
#
#  id               :bigint           not null, primary key
#  alcohol          :float
#  aminosando       :float
#  aroma_impression :text
#  aroma_value      :integer
#  awa              :string
#  bindume_on       :date
#  bottle_level     :integer          default("sealed")
#  brewery_year     :date
#  color            :string
#  emptied_at       :datetime         not null
#  genryomai        :string
#  hiire            :integer          default("unknown")
#  kakemai          :string
#  kobo             :string
#  kura             :string
#  moto             :integer          default("unknown")
#  name             :string
#  nigori           :string
#  nihonshudo       :float
#  note             :text
#  opened_at        :datetime         not null
#  price            :integer
#  rating           :integer          default(0), not null
#  roka             :string
#  sando            :float
#  season           :string
#  seimai_buai      :integer
#  shibori          :string
#  size             :integer          default(720)
#  taste_impression :text
#  taste_value      :integer
#  todofuken        :string
#  tokutei_meisho   :integer          default("none")
#  warimizu         :integer          default("unknown")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Sake < ApplicationRecord
  include BottleStateTimestampable

  has_many :photos, dependent: :destroy
  enum :bottle_level, { sealed: 0, opened: 1, empty: 2 }
  enum :hiire, { unknown: 0, namanama: 1, mae_hiire: 2, ato_hiire: 3, nido_hiire: 4, ikkai_hiire: 5 }, prefix: true
  enum :tokutei_meisho, {
    none: 0,
    honjozo: 1,
    ginjo: 2,
    daiginjo: 3,
    junmai: 4,
    junmai_ginjo: 5,
    junmai_daiginjo: 6,
    tokubetsu_honjozo: 7,
    tokubetsu_junmai: 8,
  }, prefix: true
  enum :moto, { unknown: 0, kimoto: 1, yamahai: 2, sokujo: 3, mizumoto: 4 }, prefix: true
  enum :warimizu, { unknown: 0, kasui: 1, genshu: 2 }, prefix: true

  validates :name, presence: true
  validates :kura, exclusion: { in: [nil] }
  validates :todofuken, exclusion: { in: [nil] }
  validates :taste_value, numericality: { only_integer: true }, inclusion: 0..6, allow_nil: true
  validates :aroma_value, numericality: { only_integer: true }, inclusion: 0..6, allow_nil: true
  validates :nihonshudo, numericality: { allow_nil: true }
  validates :sando, numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :aroma_impression, exclusion: { in: [nil] }
  validates :color, exclusion: { in: [nil] }
  validates :taste_impression, exclusion: { in: [nil] }
  validates :nigori, exclusion: { in: [nil] }
  validates :awa, exclusion: { in: [nil] }
  validates :tokutei_meisho, presence: true
  validates :genryomai, exclusion: { in: [nil] }
  validates :kakemai, exclusion: { in: [nil] }
  validates :kobo, exclusion: { in: [nil] }
  validates :alcohol, numericality: { allow_nil: true, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 }
  validates :aminosando, numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :season, exclusion: { in: [nil] }
  validates :warimizu, presence: true
  validates :moto, exclusion: { in: [nil] }
  validates :seimai_buai, numericality: { allow_nil: true, greater_than_or_equal_to: 0, less_than: 100 }
  validates :roka, exclusion: { in: [nil] }
  validates :shibori, exclusion: { in: [nil] }
  validates :note, exclusion: { in: [nil] }
  validates :bottle_level, presence: true
  validates :hiire, presence: true
  validates :price, numericality: { allow_nil: true, only_integer: true, greater_than_or_equal_to: 0 }
  validates :size, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :opened_at, presence: true
  validates :emptied_at, presence: true
  validates :rating, numericality: { only_integer: true }, inclusion: 0..5

  after_initialize do |sake|
    sake.opened_at ||= Time.current
    sake.emptied_at ||= Time.current
  end

  # rubocop:disable Layout/LineLength
  ransack_alias :all_text, :aroma_impression_or_awa_or_color_or_genryomai_or_kakemai_or_kobo_or_kura_or_name_or_nigori_or_note_or_roka_or_season_or_shibori_or_taste_impression_or_todofuken
  # rubocop:enable Layout/LineLength

  # Ransackでの検索許可リスト
  def self.ransackable_attributes(_auth_object = nil)
    # すべてを許可
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    # すべてを関連付け
    authorizable_ransackable_associations
  end

  # 酒が未開封か
  # @return [Boolean] 酒が未開封ならtrue、さもなくばfalse
  def sealed?
    bottle_level == "sealed"
  end

  # 酒が開封されてまだ残っているか
  # @return [Boolean] 酒が開封済みで中身が残っていたらtrue、未開封や空ならfalse
  def opened?
    bottle_level == "opened"
  end

  # 酒が空か
  # @return [Boolean] 酒が空ならtrue、未開封や開封済みならfalse
  def empty?
    bottle_level == "empty"
  end

  # 残っている酒の総量をmlで返す
  #
  # 開封済みのお酒は瓶の半量が残っているとして概算する。
  # @param include_empty [Boolean] trueなら飲んだ分も含めた総量を計算する
  # @return [Integer] 酒の総量[ml]
  def self.alcohol_stock(include_empty: false)
    if include_empty
      sum(:size)
    else
      where(bottle_level: "sealed").sum(:size) + (where(bottle_level: "opened").sum(:size) / 2)
    end
  end

  # 酒が新着ならtrue、さもなくばfalse
  #
  # 下記のいずれかに当てはまる場合は新着と判定する
  # - 未開封かつ4週間以内に購入した
  # - 開封済かつ2週間以内に購入した
  # @return [Boolean]
  def new_arrival?
    new_limit = sealed? ? 4.weeks : 2.weeks
    Time.zone.now.beginning_of_day - created_at.beginning_of_day <= new_limit
  end

  # @type [Float] 酒の売値を決めるために、仕入れ値にかける係数
  SELLING_RATE = 3.0
  private_constant :SELLING_RATE

  # 酒一合当たりの売値を計算する。
  #
  # 酒一本あたりの価格・内容量と、設定した係数をもとに計算。十の位以下切り上げ。
  # 売値が計算できない場合はnilを返す。
  # @return [Integer,nil] 酒一合当たりの売値またはnil
  def selling_price
    return if price.nil? || price.zero? || size.nil? || size.zero?

    (price.to_f / size * 180 * SELLING_RATE).ceil(-2)
  end
end
