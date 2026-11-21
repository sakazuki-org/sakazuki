/*
 * MEMO:
 * この辞書は先にヒットした内容が優先される
 * そのため、部分集合となるようなキーワードがある場合はヒットしづらいものを先に書く。
 * 例えば、純米大吟醸と大吟醸は、純米大吟醸を先に書いておく必要がある。
 */

/*
 * HACK:
 * 生や夏は、これだけでは想定外のヒットが予想される。
 * 例えば、生だけでは生酛や生道井などがヒットしてしまう。
 * そこで検索ワードは工夫している。
 * 具体的には、SAKAZUKI2年運用で出てきた酒名を参考にした。
 */

const tokuteiMeisho = [
  { keywords: ["特別本醸造"], completion: "tokubetsu_honjozo" },
  { keywords: ["本醸造"], completion: "honjozo" },
  { keywords: ["純米大吟醸"], completion: "junmai_daiginjo" },
  { keywords: ["純米吟醸"], completion: "junmai_ginjo" },
  { keywords: ["大吟醸"], completion: "daiginjo" },
  { keywords: ["吟醸"], completion: "ginjo" },
  { keywords: ["特別純米"], completion: "tokubetsu_junmai" },
  { keywords: ["純米"], completion: "junmai" },
]

const hiyaoroshiKeywords = [
  "冷卸し",
  "冷やおろし",
  "ひやおろし",
  "秋上がり",
  "秋あがり",
]
const season = [
  {
    keywords: ["新酒", "しぼりたて", "初しぼり", "はつしぼり"],
    completion: "新酒",
  },
  { keywords: ["立春朝搾り"], completion: "立春朝搾り" },
  { keywords: ["夏酒", "夏限定", "夏の", "の夏"], completion: "夏酒" },
  { keywords: hiyaoroshiKeywords, completion: "ひやおろし" },
  { keywords: ["古酒", "年熟成"], completion: "古酒" },
]

const moto = [
  { keywords: ["生酛", "生もと"], completion: "kimoto" },
  { keywords: ["山廃"], completion: "yamahai" },
  { keywords: ["速醸"], completion: "sokujo" },
  { keywords: ["水酛"], completion: "mizumoto" },
]

const shibori = [
  { keywords: ["槽搾り", "槽しぼり"], completion: "槽搾り" },
  {
    keywords: [
      "雫取り",
      "雫どり",
      "しずくどり",
      "雫囲い",
      "しずく囲い",
      "しずく搾り",
      "袋吊り",
      "吊るし酒",
      "斗瓶囲い",
      "斗瓶取り",
      "斗瓶採り",
      "斗瓶どり",
    ],
    completion: "雫取り",
  },
  {
    keywords: ["荒走り", "あらばしり"],
    completion: "あらばしり",
  },
  {
    keywords: [
      "中取り",
      "中どり",
      "なかどり",
      "中垂れ",
      "中だれ",
      "なかだれ",
      "中汲み",
      "中くみ",
      "なかくみ",
    ],
    completion: "中取り",
  },
  { keywords: ["責め"], completion: "責め" },
]

const roka = [
  { keywords: ["無濾過", "無ろ過"], completion: "無濾過" },
  { keywords: ["素濾過", "素ろ過"], completion: "素濾過" },
]

const hiire = [
  {
    keywords: [
      "生原酒",
      "しぼりたて生",
      "無濾過生",
      "無ろ過生",
      " 生 ",
      "生酒",
    ],
    completion: "namanama",
  },
  { keywords: hiyaoroshiKeywords.concat(["生詰"]), completion: "mae_hiire" },
  { keywords: ["生貯"], completion: "ato_hiire" },
  { keywords: ["一回火入れ"], completion: "ikkai_hiire" },
]

const warimizu = [{ keywords: ["原酒"], completion: "genshu" }]

export { tokuteiMeisho, season, moto, shibori, roka, hiire, warimizu }
