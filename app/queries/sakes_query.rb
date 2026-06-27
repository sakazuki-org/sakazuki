# 酒一覧(index)の検索条件を組み立てるQuery Object
#
# ユーザーの意図（検索語・空き瓶を含めるか）を受け取り、Ransackクエリと
# 表示用の一覧を組み立てる。受け取ったパラメータを書き換えず、意図から
# クエリを構築することで、コントローラと検索仕様の関心を分離する。
class SakesQuery
  # 酒一覧の並び順
  SORTS = ["bottle_level", "id desc"].freeze
  private_constant :SORTS

  # @param word [String, nil] 検索語（all_text_cont）
  # @param include_empty [Boolean, nil] 空き瓶を含めるか。nilなら未指定としてデフォルト推論する
  def initialize(word:, include_empty:)
    @word = word.presence
    # 明示指定があればそれを尊重し、未指定なら「検索語があるか」でデフォルトを決める。
    # （検索時は空き瓶を含む、通常のindexは含まない）
    @include_empty = include_empty.nil? ? searching? : include_empty
  end

  # フォーム再描画用のRansackオブジェクト
  #
  # @return [Ransack::Search]
  def ransack
    @ransack ||= Sake.ransack(ransack_query).tap { |search| search.sorts = SORTS }
  end

  # @return [Boolean] 空き瓶を含めるならtrue
  def include_empty? = @include_empty

  # @return [Boolean] 検索中ならtrue
  def searching? = @word.present?

  # @return [Boolean] デフォルトのindex表示（検索語なし & 空き瓶なし）ならtrue
  def default_index? = !searching? && !@include_empty

  # Viewへ渡す酒一覧
  #
  # デフォルトindexのみ在庫全件を1ページに表示し、それ以外（検索時・空き瓶を含む一覧）は
  # ページネーションする。
  #
  # @param page [String, Integer, nil] ページ番号
  # @return [ActiveRecord::Relation] 酒一覧
  def result(page:)
    scope = ransack.result.includes(:photos)
    scope = scope.where.not(bottle_level: :empty) unless @include_empty
    default_index? ? scope : scope.page(page)
  end

  private

  # Ransackへ渡すクエリを組み立てる
  #
  # 検索語を半角/全角空白で分割し、and検索（groupings）に変換する。
  #
  # @return [Hash] Ransackクエリ
  def ransack_query
    return {} if @word.blank?

    { groupings: @word.split(/[ 　]/).map { |word| { all_text_cont: word } } }
  end
end
