module SakesSearch
  extend ActiveSupport::Concern

  included do
    # Define any shared logic or setup here if needed
  end

  private

  # クエリを初期化する
  #
  # @param query [Hash{Symbol => String}, nil] クエリパラメータ
  # @return [Hash] not nilなコピーされたクエリ
  def initialize_query(query)
    query ? query.deep_dup : {}
  end

  # 空き瓶を表示するかどうか
  #
  # @param query [Hash{Symbol => String}] クエリパラメータ
  # @return [Boolean] 空き瓶を表示するならtrue
  def include_empty?(query)
    !query.nil? && query[:bottle_level_not_eq].to_s == Sake::BOTTOM_BOTTLE.to_s
  end

  # 検索中かどうか
  #
  # @param query [Hash{Symbol => String}, nil] クエリパラメータ
  # @return [Boolean] 検索語が入力されているならtrue
  def searching?(query)
    !query.nil? && query[:all_text_cont].present?
  end

  # 瓶状態（空き瓶の表示有無）が明示的に指定されているか
  #
  # @param query [Hash{Symbol => String}, nil] クエリパラメータ
  # @return [Boolean] 瓶状態が指定されているならtrue
  def bottle_level_specified?(query)
    !query.nil? && query[:bottle_level_not_eq].present?
  end

  # クエリに空き瓶の表示有無を反映する
  #
  # - 明示的に「含む」指定があればそのまま
  # - 検索時で瓶状態の指定がなければ、デフォルトで空き瓶を含む
  # - それ以外（通常のindex・明示的に除外）は空き瓶なし
  #
  # @param query [Hash{Symbol => String}] クエリパラメータ
  # @param searching [Boolean] 検索中ならtrue
  # @return [void]
  def apply_bottle_visibility!(query, searching:)
    return if include_empty?(query)

    if searching && !bottle_level_specified?(query)
      to_include_empty!(query)
    else
      to_default_bottle!(query)
    end
  end

  # クエリにデフォルトの瓶状態を設定する
  #
  # クエリの瓶状態が設定されていないときは、空き瓶の表示をオフにする。
  #
  # @param query [Hash{Symbol => String}] クエリパラメータ
  # @return [void]
  def to_default_bottle!(query)
    query[:bottle_level_not_eq] = Sake.bottle_levels["empty"]
  end

  # クエリを空き瓶を含む状態に設定する
  #
  # @param query [Hash{Symbol => String}] クエリパラメータ
  # @return [void]
  def to_include_empty!(query)
    query[:bottle_level_not_eq] = Sake::BOTTOM_BOTTLE
  end

  # 文字列を空白で分割して検索用文字列を生成する
  #
  # 文字列の分割には、全角空白と半角空白が認められる。
  #
  # @param words [String] 検索文字列
  # @return [Array<Hash>] 分割された検索文字列
  def separate_words(words)
    # MEMO:
    # 例えば、" 愛知 原田"のとき["", "愛知", "原田"]のように空文字列が入りうる。
    # 結果、このあとRansackに投げるクエリに{ "all_text_cont" => "" }が入りうる。
    # しかし、Ransackはこの空文字列を削除してSQL変換してくれるので、問題にならない。
    words.split(/[ 　]/).map { |word| { all_text_cont: word } }
  end

  # クエリを複数検索用に変換する
  #
  # @param query [Hash] クエリパラメータ
  # @return [void]
  def to_multi_search!(query)
    words = query.delete(:all_text_cont)
    query[:groupings] = separate_words(words)
  end
end
