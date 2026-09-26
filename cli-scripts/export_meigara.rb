#!/usr/bin/env ruby

# kura-list.ndjsonを使って、megaras.tsを生成するスクリプト

require "json"

# kura-list.ndjsonを読み込む
#
# @return [Array<Hash{Symbol => String, Array<String>}>] 蔵、地域、銘柄を持つjsonの配列
def read_kura
  filename = "#{__dir__}/kura-list.ndjson"
  file = File.new(filename)
  jsons = []
  file.each_line do |line|
    json = JSON.parse(line)
    json = { name: json["name"], region: json["region"], meigaras: json["meigaras"] }
    jsons.append(json)
  end
  jsons
end

# 複数の銘柄を持つjsonを分けてフラットにする
#
# 1つの蔵に複数の代表銘柄がありうる。
# 銘柄から蔵を補完するには1つの銘柄から1つの蔵が決まる必要がある。
# そのため、この関数は入力された複数銘柄を持つjsonを1銘柄ずつにフラットに分解する。
#
# @param jsons [Array<Hash{Symbol => String, Array<String>}>] kura-list.ndjsonから読み取ったjsonの配列
# @return [Array<Hash{Symbol => String}>] 銘柄をflattenしたjsonの配列
def flatten_by_meigara(jsons)
  jsons.flat_map { |json|
    case json
    in { name: name, region: region, meigaras: meigaras }
      meigaras.map { |meigara|
        { name:, region:, meigara: }
      }
    end
  }
end

# jsonの銘柄が銘柄リストに含まれるかどうか
#
# @param json [Hash{Symbol => String}] 蔵、地域、銘柄を持つjson
# @param meigaras [Array<String>] 銘柄のリスト
# @return [Booleann] 含まれるならtrue
def include_meigara?(json, meigaras)
  meigara = json[:meigara]
  meigaras.include?(meigara)
end

# 銘柄が重複するjsonを除外する
#
# 銘柄から蔵を補完するには、銘柄から蔵が一意に決まる必要がある。
# そのため、同じ代表銘柄を持つ蔵は補完の対象外とするため、除外する。
#
# @param jsons [Array<Hash{Symbol => String}>] 蔵、地域、銘柄を持つjsonの配列
# @return [Array<Hash{Symbol => String}>] 銘柄名が重複するものが除かれた配列
def remove_duplication(jsons)
  uniqed = jsons.uniq { |json| json[:meigara] }
  duplications = jsons.difference(uniqed)
  # rubocop:disable-next Rails/Pluck
  duplications = duplications.map { |json| json[:meigara] }
  jsons.reject { |json| include_meigara?(json, duplications) }
end

# 同社の別蔵で代表銘柄が被っていたものを復元する
#
# 例えば銘柄「酔鯨」をつくるのは酔鯨酒造と酔鯨酒造土佐蔵の2つがある。
# このように同じ会社の別蔵があり銘柄が重複する場合は、代表蔵で復元する。
#
# @param jsons [Array<Hash{Symbol => String}>] 蔵、地域、銘柄を持つjsonの配列
# @return [Array<Hash{Symbol => String}>] 一部銘柄が復元された配列
def add_exceptional_duplication(jsons)
  jsons + [
    { name: "大関株式会社", region: "兵庫県", meigara: "大関" },
    { name: "太田酒造株式会社", region: "滋賀県", meigara: "道灌" },
    { name: "長龍酒造株式会社", region: "奈良県", meigara: "長龍" },
    { name: "酔鯨酒造株式会社", region: "高知県", meigara: "酔鯨" },
  ]
end

# 銘柄から蔵・地域への辞書にする
#
# 例えば、"生道井"がキー、"原田酒造合名会社（愛知県）"が値のような、辞書Hashを作成する。
#
# @param jsons [Array<Hash{Symbol => String}>] 蔵、地域、銘柄を持つjsonの配列
# @return [Array<Hash{String => String}>] 銘柄から蔵・地域への辞書Hash
def to_dict(jsons)
  dict = {}
  jsons.each do |json|
    key = json[:meigara]
    value = "#{json[:name]}（#{json[:region]}）"
    dict[key] = value
  end
  dict
end

# 銘柄から蔵・地域への辞書HashをTypeScriptファイルへ出力する
#
# @note 出力されるTypeScriptはprettierされておらず手動でかける必要がある。
#
# @param filename [String] 出力先のファイル名
# @param dict [Array<Hash{String => String}>] 銘柄から蔵・地域への辞書Hash
def write_dict(filename, dict)
  File.open(filename, "wb") do |file|
    file.write("export const dict = ")
    file.write(JSON.pretty_generate(dict))
    file.write("\n")
  end
end

# メイン関数
def main
  jsons = read_kura
  jsons = flatten_by_meigara(jsons)
  jsons = remove_duplication(jsons)
  jsons = add_exceptional_duplication(jsons)
  dict = to_dict(jsons)

  filename = "#{__dir__}/../app/javascript/completion/meigara_dict.ts"
  write_dict(filename, dict)

  puts("Done!")
  puts("Output to '#{filename}'")
  puts("Please run `yarn run lint:prettier:fix`")
end

main
