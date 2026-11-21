class SakesController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :set_sake, only: %i[show edit update destroy]
  before_action :signed_in_user, only: %i[new edit update destroy]
  # update と destroy は JSON の応答を持たないので、トークンでは通さない
  # prependを外すとCSRF検証が先に走り、トークンなしのJSONのPOSTが401でなく422になる
  prepend_before_action :signed_in_user_or_api_token, only: %i[create]

  include SakesPhotos
  include SakesSearch

  # GET /sakes
  def index
    respond_to do |format|
      format.html { build_index_search }
      format.json { render_json_list }
    end
  end

  # GET /sakes/1
  def show
    respond_to do |format|
      format.html
      format.json { render(json: sake_json(@sake)) }
    end
  end

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
    return render_invalid(:new) unless @sake.save

    @sake.initialize_bottle_state_timestamps
    respond_to do |format|
      format.html do
        store_photos(@sake, sake_params)
        redirect_to(@sake, status: :see_other, flash: { create_sake: { name: @sake.name, id: @sake.id } })
      end
      format.json { render(json: sake_json(@sake), status: :created, location: @sake) }
    end
  end

  # PATCH/PUT /sakes/1
  # rubocop:disable-next Metrics/MethodLength
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

  # ブラウザはAuthorizationヘッダーを自動で付けないので、トークン認証のリクエストはCSRFの対象にならない。
  # 「JSONなら通す」にすると、ログイン中のブラウザに罠ページからJSONをPOSTさせる攻撃が通る。
  # トークンで通すcreateだけに絞り、ログイン中のブラウザがトークンも送ったときにupdateやdestroyまで通さない。
  def verified_request?
    super || (action_name == "create" && api_token_authenticated?)
  end

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
      brewery_year: Sake.to_by(Date.current),
      bindume_on: Date.current.beginning_of_month,
    }
  end

  # JSON APIで返す酒オブジェクトを作る
  #
  # @param sake [Sake] 酒オブジェクト
  # @return [Hash] sakesの全カラムと写真のURL
  def sake_json(sake)
    photos = sake.photos.map { |photo| { id: photo.id, url: photo.image.url, thumb_url: photo.image.thumb.url } }
    sake.as_json.merge(photos:)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_sake
    @sake = Sake.includes(:photos).find(params.expect(:id))
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

  # 保存に失敗した酒の検証エラーを返す
  #
  # @param template [Symbol] HTMLで再表示するテンプレート
  def render_invalid(template)
    respond_to do |format|
      format.html { render(template, status: :unprocessable_content) }
      format.json { render(json: { errors: @sake.errors }, status: :unprocessable_content) }
    end
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
