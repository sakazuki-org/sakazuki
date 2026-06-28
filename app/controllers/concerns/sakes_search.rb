# 酒一覧(index)の検索条件を組み立てるconcern
#
# ユーザーの意図（検索語・空き瓶を含めるか）をparamsから解釈し、Ransackクエリと
# 表示用の一覧（@search/@sakes）を組み立てる。検索仕様の関心をコントローラから分離する。
module SakesSearch
  extend ActiveSupport::Concern

  # 酒一覧の並び順
  SORTS = ["bottle_level", "id desc"].freeze
  private_constant :SORTS

  included do
    # Viewでも検索状態を参照できるようにする
    helper_method :searching?, :include_empty?, :default_index?
  end

  private

  # index用にRansackオブジェクトと酒一覧を組み立て、@search/@sakesへ設定する
  #
  # デフォルトindex（検索語なし & 空き瓶なし）のみ在庫を全件1ページに表示し、
  # それ以外（検索時・空き瓶を含む一覧）はページネーションする。
  #
  # @return [void]
  def build_index_search
    @search = Sake.ransack(ransack_query).tap { |search| search.sorts = SORTS }
    scope = @search.result.includes(:photos)
    scope = scope.where.not(bottle_level: :empty) unless include_empty?
    @sakes = default_index? ? scope : scope.page(params[:page])
  end

  # @return [String, nil] 検索語（all_text_cont）。空文字列はnilとして扱う
  def search_word
    params.dig(:q, :all_text_cont).presence
  end

  # @return [Boolean] 検索中ならtrue
  def searching?
    search_word.present?
  end

  # 空き瓶を含めて表示するかどうか
  #
  # トグルスイッチによる空き瓶を含む・含まないの明示指定（intent）があればそれを尊重する。
  # 未指定なら「検索中かどうか」でデフォルトを決める。
  # 検索時は空き瓶を含む、通常のindexは含まない。
  #
  # @return [Boolean] 空き瓶を含めるならtrue
  def include_empty?
    return @include_empty if defined?(@include_empty)

    intent = include_empty_intent
    @include_empty = intent.nil? ? searching? : intent
  end

  # トグルスイッチによる空き瓶を含めるか指示があったか
  #
  # ユーザーがトグルスイッチで明示的に空き瓶を含める・含めないを指定した場合は true/false を返す。
  # 検索ボタン経由では nil を返す。
  #
  # @return [true, false, nil]
  #   - true: 空き瓶を含む
  #   - false: 空き瓶を含まない
  #   - nil: 未指定
  def include_empty_intent
    return if params[:commit].present?

    boolean_param(params[:include_empty])
  end

  # パラメータの真偽値を解釈する
  #
  # 「未指定（nil）」と「明示的なfalse」を区別できるよう、nilはnilのまま返す。
  #
  # @param value [String, nil] パラメータ値
  # @return [Boolean, nil] 真偽値。未指定ならnil
  def boolean_param(value)
    return if value.nil?

    ActiveModel::Type::Boolean.new.cast(value)
  end

  # @return [Boolean] デフォルトのindex表示（検索語なし & 空き瓶なし）ならtrue
  def default_index?
    !searching? && !include_empty?
  end

  # Ransackへ渡すクエリを組み立てる
  #
  # 検索語を半角/全角空白で分割し、and検索（groupings）に変換する。
  #
  # @return [Hash] Ransackクエリ
  def ransack_query
    return {} if search_word.blank?

    { groupings: search_word.split(/[ 　]/).map { |word| { all_text_cont: word } } }
  end
end
