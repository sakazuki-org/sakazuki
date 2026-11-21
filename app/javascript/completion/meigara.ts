/**
 * 蔵名の補完辞書
 *
 * 銘柄と蔵は数がそれなりに多い。
 * そのため、銘柄から一意の蔵が決まる辞書を使う。
 */
export type Dict = Record<string, string>

/**
 * 酒の名前と補完辞書から補完する文字列を探す
 *
 * 補完候補が複数ある場合は、酒名前にて先に出てきた銘柄名を優先する。
 *
 * 酒の名前を空白で区切って、それらの中に登録された銘柄があるかを確認する。
 * そのため、現状は「kamosu mori」のような空白が入っている銘柄に対応できない。
 * アルゴリズムの再考と複雑化が見込まれるため、対応していない。
 *
 * @param name 酒の名前
 * @param dict 補完辞書
 * @returns 補完する蔵名、補完できないなら空文字を返す
 */
export function lookup(name: string, dict: Dict): string {
  const words = name.split(RegExp(/\s/))
  const nonNullable = <Type>(value: Type): value is NonNullable<Type> =>
    value != null
  const matchedWords = words
    .map((word) => {
      return dict[word]
    })
    .filter(nonNullable)
  return matchedWords.shift() ?? ""
}
