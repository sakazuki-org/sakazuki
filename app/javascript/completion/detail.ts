/**
 * 酒情報の補完候補
 *
 * 「雫取り」、「袋吊り」のように複数種から「雫取り」1種に補完する。
 * そのため、補完に対してキーワードは複数存在する候補となっている。
 */
export type Candidate = {
  /** このキーワードが含まれていたら補完を行う */
  readonly keywords: readonly string[]
  /** 補完に使う文字列 */
  readonly completion: string
}

/** 酒情報の補完辞書 */
export type Dict = readonly Candidate[]

/**
 * 指定した複数文字列のいずれか1つでも含まれるかをチェックする
 *
 * String.includesの複数候補版。
 *
 * @param target 検索対象の文字列
 * @param keywords 検索する複数キーワード
 * @returns 検索対象にいずれかのキーワードが1つでも含まれればtrue
 */
function includesAny(target: string, keywords: readonly string[]): boolean {
  return keywords.some((word) => {
    return target.includes(word)
  })
}

/**
 * 補完候補を採用するかチェックする
 *
 * @param name 酒の名前
 * @param cand 補完候補
 * @returns 採用されれば補完候補、採用されなければ空文字列を返す
 */
function check(name: string, cand: Candidate): string {
  return includesAny(name, cand.keywords) ? cand.completion : ""
}

/**
 * 酒の名前と補完辞書から補完する文字列を探す
 *
 * @param name 酒の名前
 * @param dict 補完辞書
 * @returns 補完できるなら補完候補、補完できないなら空文字を返す
 */
export function lookup(name: string, dict: Dict): string {
  const found = dict.find((cand) => {
    return check(name, cand) !== ""
  })
  return found?.completion ?? ""
}
