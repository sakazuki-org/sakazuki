import { Controller } from "@hotwired/stimulus"
import zip from "just-zip-it"
import * as meigaraDict from "../completion/meigara_dict"
import * as meigara from "../completion/meigara"
import * as detailDict from "../completion/detail_dict"
import * as detail from "../completion/detail"

/**
 * 補完機構
 *
 * 入力文字列から、対応する補完情報を出力する
 */
type Completion = (input: string) => string

/** 補完対象 */
type Target = {
  readonly element: HTMLInputElement | HTMLSelectElement
  readonly empty: string
}

// Connects to data-controller="sake-name"
export default class SakeNameController extends Controller<HTMLDivElement> {
  static targets = [
    "name",
    "kura",
    "tokuteiMeisho",
    "season",
    "moto",
    "shibori",
    "roka",
    "hiire",
    "warimizu",
  ]

  declare readonly nameTarget: HTMLInputElement

  declare readonly kuraTarget: HTMLInputElement

  declare readonly tokuteiMeishoTarget: HTMLSelectElement

  declare readonly seasonTarget: HTMLInputElement

  declare readonly motoTarget: HTMLSelectElement

  declare readonly shiboriTarget: HTMLSelectElement

  declare readonly rokaTarget: HTMLInputElement

  declare readonly hiireTarget: HTMLSelectElement

  declare readonly warimizuTarget: HTMLSelectElement

  /**
   * 酒の名前から補完を行う
   *
   * 補完対象が空のときのみ補完を行う。
   * 未入力状態かは補完対象の`target.element`の値が`target.empty`と同じかで判定する。
   *
   * @param name 酒の名前
   * @param completion 補完機構
   * @param target 補完対象
   */
  private complete(name: string, completion: Completion, target: Target) {
    console.log("target:", target)
    if (target.element.value === target.empty) {
      const cand = completion(name)
      if (cand !== "") {
        console.log("cand:", cand)
        target.element.value = cand
        target.element.dispatchEvent(new Event("change"))
      }
    }
  }

  /**
   * 酒名を入力されたときに各種酒情報の補完を行う
   */
  private readonly handleNameChange = () => {
    const name = this.nameTarget.value

    // 蔵名の補完
    const kuraCompletions = [
      (name: string) => meigara.lookup(name, meigaraDict.dict),
    ]
    const kuraTargets: Target[] = [{ element: this.kuraTarget, empty: "" }]

    // 酒情報の補完
    const dicts = [
      detailDict.tokuteiMeisho,
      detailDict.season,
      detailDict.moto,
      detailDict.shibori,
      detailDict.roka,
      detailDict.hiire,
      detailDict.warimizu,
    ]
    const detailCompletions = dicts.map(
      (dict) => (name: string) => detail.lookup(name, dict),
    )
    const detailTargets: Target[] = [
      { element: this.tokuteiMeishoTarget, empty: "none" },
      { element: this.seasonTarget, empty: "" },
      { element: this.motoTarget, empty: "unknown" },
      { element: this.shiboriTarget, empty: "" },
      { element: this.rokaTarget, empty: "" },
      { element: this.hiireTarget, empty: "unknown" },
      { element: this.warimizuTarget, empty: "unknown" },
    ]

    const completions = kuraCompletions.concat(detailCompletions)
    const targets = kuraTargets.concat(detailTargets)
    zip(completions, targets).forEach(([completion, target]) => {
      this.complete(name, completion, target)
    })
  }

  connect() {
    this.nameTarget.addEventListener("change", this.handleNameChange)
  }

  disconnect() {
    this.nameTarget.removeEventListener("change", this.handleNameChange)
  }
}
