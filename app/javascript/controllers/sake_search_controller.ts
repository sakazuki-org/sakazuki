import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sake-search"
export default class SakeSearchController extends Controller<HTMLFormElement> {
  static targets = ["word", "includeEmpty"]

  declare readonly wordTarget: HTMLInputElement

  declare readonly includeEmptyTarget: HTMLInputElement

  /**
   * 検索を実行するとき、検索語があれば空き瓶を含めるトグルをONにする
   *
   * 検索ボタンのクリックや検索フォームでのEnterから呼ばれる。
   * トグル自体のonChangeからは呼ばれないため、検索中にユーザーが明示的に
   * トグルをOFFにして空き瓶を除外した状態は維持される。
   */
  includeEmptyOnSearch(): void {
    if (this.wordTarget.value.trim() !== "") {
      this.includeEmptyTarget.checked = true
    }
  }
}
