import { Controller } from "@hotwired/stimulus"
import SimpleLightbox from "simplelightbox"

// Connects to data-controller="simple-lightbox"
export default class SimpleLightboxController extends Controller<HTMLDivElement> {
  private lightbox: SimpleLightbox | null = null

  connect() {
    this.lightbox = new SimpleLightbox(".photo-gallery a", {
      fadeSpeed: 100,
      animationSlide: false,
      history: false,
      close: false,
      fileExt: false,
    })
  }

  disconnect() {
    if (this.lightbox !== null) {
      this.lightbox.destroy()
      this.lightbox = null
    }
  }
}
