import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share"
export default class ShareController extends Controller<HTMLDivElement> {
  static values = {
    title: String,
    url: String,
  }

  declare readonly titleValue: string

  declare readonly urlValue: string

  static targets = ["text", "link"]

  declare readonly textTarget: HTMLTextAreaElement

  declare readonly linkTarget: HTMLAnchorElement

  /**
   * シェアボタンを押したときの処理
   */
  private readonly handleShareClick = () => {
    const data: ShareData = {
      title: this.titleValue,
      text: this.textTarget.value,
      url: this.urlValue,
    }
    void navigator.share(data)
  }

  connect() {
    this.linkTarget.addEventListener("click", this.handleShareClick)
  }

  disconnect() {
    this.linkTarget.removeEventListener("click", this.handleShareClick)
  }
}
