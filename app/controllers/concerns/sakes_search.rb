# 酒一覧(index)の検索条件を組み立てるconcern
#
# ユーザーの検索語をparamsから解釈し、Ransackクエリと表示用の一覧（@search/@sakes/@amount）を
# 組み立てる。検索仕様の関心をコントローラから分離する。
module SakesSearch
  extend ActiveSupport::Concern

  # 酒一覧の並び順
  SORTS = ["bottle_level", "id desc"].freeze
  private_constant :SORTS

  included do
    # Viewでも検索状態を参照できるようにする
    helper_method :searching?, :search_word
  end

  private

  # index用にRansackオブジェクトと酒一覧・本数・酒量を組み立てる
  #
  # @search/@sakes/@count@amount が設定される。
  #
  # @return [void]
  def build_index_search
    @search = Sake.ransack(ransack_query).tap { |search| search.sorts = SORTS }
    searching? ? build_search_result : build_stock_list
  end

  # 検索結果の一覧を組み立てる
  #
  # 空き瓶を含む全酒が対象で、ページネーションする。
  #
  # @return [void]
  def build_search_result
    listed = @search.result
    @sakes = listed.page(params[:page]).includes(:photos).load
    # @sakes はページネーションされるので、Kaminari の total_count で総数を数える
    @count = @sakes.total_count
    # @sakes を使うと複数写真を持つ酒が重複して集計されてしまう
    @amount = listed.sum(:size)
  end

  # 在庫一覧を組み立てる
  #
  # 空き瓶を除いた在庫を全件1ページに表示する。
  #
  # @return [void]
  def build_stock_list
    @sakes = @search.result.where.not(bottle_level: :empty).includes(:photos).load
    # Ruby 配列は O(1) で配列長計算できるので SQL を使わなくて良い
    @count = @sakes.size
    @amount = Sake.alcohol_stock
  end

  # params から検索語を取り出す
  #
  # @return [String, nil] 検索語（all_text_cont）。空文字列はnilとして扱う
  def search_word
    params.dig(:q, :all_text_cont).presence
  end

  # 検索フォームを使って検索中か
  #
  # 検索語が空でも true を返し、全酒の一覧モードとして使う。
  #
  # @return [Boolean] 検索中ならtrue
  def searching?
    params[:q].present?
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
