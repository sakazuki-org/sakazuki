import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sake-kura"
export default class SakeKuraController extends Controller<HTMLDivElement> {
  static targets = ["kura", "todofuken", "mixed"]

  declare readonly kuraTarget: HTMLInputElement

  declare readonly todofukenTarget: HTMLInputElement

  declare readonly mixedTarget: HTMLInputElement

  /** 隠れた蔵名・都道府県名を使って、蔵フォームを正しく埋める */
  private loadKuraTodofuken() {
    this.mixedTarget.value =
      this.kuraTarget.value && this.todofukenTarget.value
        ? `${this.kuraTarget.value}（${this.todofukenTarget.value}）`
        : this.kuraTarget.value
  }

  /**
   * 蔵名と都道府県名を分離する
   *
   * @param kuraTodofuken 入力された蔵情報
   * @returns
   * 蔵名と都道府県のタプル。
   * ただし分割失敗した場合は、第一要素に入力そのまま、第二要素に空文字を返す。
   */
  private stripKuraTodofuken(kuraTodofuken: string): [string, string] {
    // フォーマットは"蔵名（県名）"
    const formatRegexp = /^([^（]+)（([^）]+)）$/
    const result = formatRegexp.exec(kuraTodofuken)
    const kura = result?.[1] ?? kuraTodofuken
    const todofuken = result?.[2] ?? ""
    return [kura, todofuken]
  }

  /**
   * 蔵情報の同期機能をオンにする
   *
   * 蔵情報を入力すると、隠れた蔵名・都道府県名のフィールドに同期する
   */
  private readonly handleMixedChange = () => {
    const autoCompleted = this.mixedTarget.value
    const [kura, todofuken] = this.stripKuraTodofuken(autoCompleted)
    this.kuraTarget.value = kura
    this.todofukenTarget.value = todofuken
  }

  connect() {
    this.loadKuraTodofuken()
    this.mixedTarget.addEventListener("change", this.handleMixedChange)
  }

  disconnect() {
    this.mixedTarget.removeEventListener("change", this.handleMixedChange)
  }
}
