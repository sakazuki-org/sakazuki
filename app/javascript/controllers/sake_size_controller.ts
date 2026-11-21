import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sake-size"
export default class SakeSizeController extends Controller<HTMLDivElement> {
  static targets = ["radio", "otherRadio", "otherSize", "size"]

  declare readonly radioTargets: HTMLInputElement[]

  declare readonly otherRadioTarget: HTMLInputElement

  declare readonly otherSizeTarget: HTMLInputElement

  declare readonly sizeTarget: HTMLInputElement

  /**
   * その他酒サイズの入力フォームのenable/disableを管理する
   *
   * その他radioボタンが選ばれているときは、入力フォームを有効化し値必須にする。
   */
  updateOtherSizeEnablement(): void {
    this.otherSizeTarget.disabled = !this.otherRadioTarget.checked
    this.otherSizeTarget.required = this.otherRadioTarget.checked
  }

  /** 本当の酒サイズフォームにその他酒サイズを書き込む */
  writeHiddenWithOtherSize(): void {
    this.sizeTarget.value = this.otherSizeTarget.value
  }

  /**
   * 本当の酒サイズフォームを押されたradioボタンの数値によって書き込む
   *
   * @param event コントローラの呼び出し元イベント
   */
  writeHiddenByRadio(event: Event): void {
    const elem = event.currentTarget as HTMLInputElement
    const size = elem.dataset.sakeSize
    if (size == null) return // error

    if (size == "other") this.writeHiddenWithOtherSize()
    else this.sizeTarget.value = size
  }

  /** その他酒サイズフォームに本当の酒サイズを書き込む */
  private writeOtherSizeWithHidden(): void {
    this.otherSizeTarget.value = this.sizeTarget.value
  }

  /** 初期表示時に本当の酒サイズを読み込み、適切なradioにチェックをつける */
  private readHiddenSize(): void {
    const hiddenSize = this.sizeTarget.value
    const matchedRadio = this.radioTargets.find(
      (elem) => elem.dataset.sakeSize == hiddenSize,
    )

    // 選択肢にないサイズでフォームを埋める
    if (matchedRadio == null) this.writeOtherSizeWithHidden()

    // 酒サイズに合うradioにチェックをつける
    const radio = matchedRadio ?? this.otherRadioTarget
    radio.checked = true

    this.updateOtherSizeEnablement()
  }

  connect() {
    this.readHiddenSize()
  }
}
