# rubocop:disable Metrics/ClassLength
class SakesController < ApplicationController
  before_action :set_sake, only: %i[show edit update destroy]
  before_action :signed_in_user, only: %i[new create edit update destroy]

  include SakesHelper
  include SakesSearch
  include SakesPhotos

  # Viewで使える用に宣言する
  helper_method :include_empty?

  # GET /sakes
  def index
    # コピーとnil防止
    query = initialize_query(params[:q])
    # デフォルトは空き瓶なし
    to_default_bottle!(query) unless include_empty?(query)
    # 空白区切りでandサーチ
    to_multi_search!(query) if query[:all_text_cont]

    # Ransack search and sort
    @search = Sake.ransack(query)
    @search.sorts = ["bottle_level", "id desc"]
    @sakes = @search.result.includes(:photos)

    # Kaminari pager
    @sakes = @sakes.page(params[:page]) if include_empty?(query)
  end

  # GET /sakes/1
  def show; end

  # GET /sakes/new
  def new
    copied_id = params[:copied_from]
    if copied_id
      copied = Sake.find(copied_id)
      attr = copy_attributes(copied)
      @sake = Sake.new(attr)
      flash[:copy_sake] = { name: copied.name, id: copied_id }
    else
      @sake = Sake.new(default_attributes)
    end
  end

  # GET /sakes/1/edit
  def edit
    # 開けたボタン経由での処理
    @sake.bottle_level = params["sake"]["bottle_level"] if params.dig(:sake, :bottle_level)
  end

  # POST /sakes
  def create
    @sake = Sake.new(sake_params.except(:photos))

    if @sake.save
      @sake.initialize_bottle_state_timestamps
      store_photos(@sake, sake_params)
      redirect_to(@sake, status: :see_other, flash: { create_sake: { name: @sake.name, id: @sake.id } })
    else
      render(:new, status: :unprocessable_content)
    end
  end

  # PATCH/PUT /sakes/1
  # rubocop:disable Metrics/MethodLength
  def update
    if @sake.update(sake_params.except(:photos))

      delete_photos(@sake, params)
      store_photos(@sake, sake_params)

      if @sake.saved_changes? || delete_photos?(@sake, params) || store_photos?(sake_params)
        @sake.update_bottle_state_timestamps
        flash_after_update
      end

      redirect_after_update
    else
      render(:edit, status: :unprocessable_content)
    end
  end
  # rubocop:enable Metrics/MethodLength

  # DELETE /sakes/1
  def destroy
    name = @sake.name
    @sake.destroy!
    redirect_to(sakes_url, status: :see_other, flash: { delete_sake: name })
  end

  # GET /sakes
  def menu
    query = { bottle_level_not_eq: Sake.bottle_levels["empty"], s: "id desc" }
    @sakes = Sake.includes(:photos).ransack(query).result
  end

  private

  # コピー機能の対象キーかどうか
  #
  # @param key [Symbol] 酒カラム
  # @return [Boolean] コピー対象のキーならtrue
  def copy_key?(key)
    %w[
      alcohol aminosando bindume_on brewery_year genryomai hiire kakemai kobo
      kura moto name nihonshudo price roka sando season seimai_buai shibori
      size todofuken tokutei_meisho warimizu
    ].include?(key)
  end

  # コピーする酒情報を持ったハッシュを作成する
  #
  # @param sake [Sake] コピーする対象の酒オブジェクト
  # @return [Hash{Symbol => String, Integer, Date}] コピーする酒情報のハッシュ
  def copy_attributes(sake)
    all = sake.attributes
    all.select { |key, _v| copy_key?(key) }
  end

  # 新規酒のデフォルト情報をもったハッシュを作成する
  #
  # @return [Hash{Symbol => Integer, Date}] デフォルト酒情報のハッシュ
  def default_attributes
    {
      brewery_year: to_by(Date.current),
      bindume_on: Date.current.beginning_of_month,
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_sake
    @sake = Sake.includes(:photos).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sake_params
    params.expect(
      sake: [
        :name, :kura, :bindume_on, :brewery_year, :todofuken, :taste_value, :aroma_value, :nihonshudo,
        :sando, :aroma_impression, :color, :taste_impression, :nigori, :awa, :tokutei_meisho, :genryomai,
        :kakemai, :kobo, :alcohol, :aminosando, :season, :warimizu, :moto, :seimai_buai, :roka, :shibori,
        :note, :bottle_level, :hiire, :size, :price, :rating, { photos: [] }
      ],
    )
  end

  # update後のリダイレクト処理
  #
  # 編集画面からupdateする場合、詳細ページにリダイレクトする。
  # HTTP_REFERERが設定されていない場合、詳細ページにリダイレクトする。
  # 上記のどちらにも当てはまらない場合、ユーザーが直前にいたページにリダイレクトする。
  def redirect_after_update
    if update_from_edit?
      redirect_to(@sake, status: :see_other)
    else
      redirect_back_or_to(@sake)
    end
  end

  # @return [Boolean] 編集画面からUpdateが行われたらtrueを返す
  def update_from_edit?
    request.referer&.match?(%r{/sakes/[0-9]+/edit})
  end

  # update後のフラッシュメッセージ表示
  #
  # 開封するボタン・空にするボタンからupdateした場合は、専用のフラッシュメッセージを表示する
  def flash_after_update
    key = (params["drink_button"] || :update_sake).to_sym
    flash[key] = { name: @sake.name, id: @sake.id } # rubocop:disable Rails/ActionControllerFlashBeforeRender
  end
end
# rubocop:enable Metrics/ClassLength
