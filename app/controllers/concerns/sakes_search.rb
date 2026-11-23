# 酒一覧(index)の検索条件を組み立てるconcern
#
# ユーザーの検索語をparamsから解釈し、Ransackクエリと表示用の一覧（@search/@sakes/@amount）を
# 組み立てる。検索仕様の関心をコントローラから分離する。
module SakesSearch
  extend ActiveSupport::Concern

  # 酒一覧の並び順
  SORTS = ["bottle_level", "id desc"].freeze
  private_constant :SORTS

  # pageに上限がないと、OFFSETがbigintを超えてActiveRecord::RangeErrorの500になる
  JSON_PAGE_PARAMS = { page: 1..1_000_000, per: 1..100 }.freeze
  private_constant :JSON_PAGE_PARAMS

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

  # JSON API用の酒一覧を返す。ページ指定が不正なら400とエラーを返す
  #
  # @return [void]
  def render_json_list
    errors = json_page_errors
    return render(json: { errors: }, status: :bad_request) if errors.any?

    render(json: json_list)
  end

  # Kaminariは不正なpageとperを黙って既定値に直すが、per=0だけは500になる。
  # 直さずに400で返し、クライアントが誤りに気付けるようにする。
  #
  # @return [Hash{Symbol => Array<String>}] 不正なページ指定のエラー
  def json_page_errors
    JSON_PAGE_PARAMS.filter_map { |key, range|
      value = params[key]
      next if value.nil?

      if !value.to_s.match?(/\A-?\d+\z/)
        [key, [t("errors.messages.not_an_integer")]]
      elsif !range.cover?(value.to_i)
        [key, [t("errors.messages.in", count: range)]]
      end
    }.to_h
  end

  # JSON API用の酒一覧とページ情報を返す
  #
  # HTMLと違い、検索の有無にかかわらず空き瓶を含む全酒をページネーションする。
  #
  # @return [Hash] sakesとmetaを持つハッシュ
  def json_list
    sakes = json_sakes
    meta = {
      page: sakes.current_page,
      per: sakes.limit_value,
      total_pages: sakes.total_pages,
      total_count: sakes.total_count,
    }
    { sakes: sakes.map { |sake| sake_json(sake) }, meta: }
  end

  # @return [ActiveRecord::Relation] ページネーションしたJSON API用の酒
  def json_sakes
    search = Sake.ransack(ransack_query.merge(json_filters)).tap { |s| s.sorts = SORTS }
    search.result.page(params[:page]).per(params[:per]).includes(:photos)
  end

  # Ransackに任意の条件を渡すと未知の述語で500になるため、瓶の状態の絞り込みだけを受け付ける
  #
  # @return [Hash] 瓶の状態のRansack条件
  def json_filters
    params.fetch(:q, {}).permit(:bottle_level_eq, :bottle_level_not_eq).to_h
  end

  # params から検索語を取り出す
  #
  # @return [String, nil] 検索語（all_text_cont）。空文字列はnilとして扱う
  # @raise [ActionController::BadRequest] qがハッシュでない、または検索語が文字列でないとき
  def search_word
    q = params.fetch(:q, {})
    raise(ActionController::BadRequest, "q must be a hash") unless q.is_a?(ActionController::Parameters)

    word = q[:all_text_cont]
    raise(ActionController::BadRequest, "q[all_text_cont] must be a string") unless word.nil? || word.is_a?(String)

    word.presence
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
