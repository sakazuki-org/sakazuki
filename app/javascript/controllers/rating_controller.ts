import { Controller } from "@hotwired/stimulus"
import rater from "rater-js"
import type { Rater } from "rater-js"

// Connects to data-controller="rating"
export default class RatingController extends Controller<HTMLFieldSetElement> {
  static targets = ["score", "location"]

  declare readonly scoreTarget: HTMLInputElement

  declare readonly locationTarget: HTMLDivElement

  private sakeRater: Rater | null = null

  connect() {
    const rating = parseInt(this.scoreTarget.value)
    this.sakeRater = rater({
      element: this.locationTarget,
      rateCallback: (newRating, done) => {
        if (this.sakeRater === null) return

        // reset 0, when pushing same star
        if (newRating === this.sakeRater.getRating()) newRating = 0

        this.sakeRater.setRating(newRating)
        this.scoreTarget.value = newRating.toString()

        done()
      },
      rating,
      starSize: 32,
    })
  }

  disconnect() {
    if (this.sakeRater !== null) {
      this.sakeRater.dispose()
      this.sakeRater = null
    }
  }
}
