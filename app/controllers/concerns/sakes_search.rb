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

  # index用にRansackオブジェクトと酒一覧・酒量を組み立て、@search/@sakes/@amountへ設定する
  #
  # 検索していないときは在庫（空き瓶以外）を全件1ページに表示する。
  # 検索時は空き瓶を含む全酒が対象で、ページネーションする。
  #
  # @return [void]
  def build_index_search
    @search = Sake.ransack(ransack_query).tap { |search| search.sorts = SORTS }
    scope = @search.result.includes(:photos)
    @sakes = searching? ? scope.page(params[:page]) : scope.where.not(bottle_level: :empty)
    @amount = alcohol_amount
  end

  # 見出しに出す酒量
  #
  # 検索時はヒットした酒の総量、検索していないときは在庫量を返す。
  # 集計には@sakesではなくページネーション前のスコープを使う。@sakesはLIMITがかかり、
  # ページに載っている分しか数えられない。
  #
  # @return [Integer] 酒量[ml]
  def alcohol_amount
    searching? ? @search.result.sum(:size) : Sake.alcohol_stock
  end

  # @return [String, nil] 検索語（all_text_cont）。空文字列はnilとして扱う
  def search_word
    params.dig(:q, :all_text_cont).presence
  end

  # 検索フォームから来たか
  #
  # 検索語が空でも全酒の一覧として扱う。今までに買った酒を振り返るために使う。
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
