import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-tax"
export default class AddTaxController extends Controller<HTMLDivElement> {
  static targets = ["price", "button"]

  declare readonly priceTarget: HTMLInputElement

  declare readonly buttonTarget: HTMLButtonElement

  private addTax = () => {
    const price = this.priceTarget.valueAsNumber
    if (isNaN(price)) return

    const TAX_RATE = 1.1
    const newPrice = Math.floor(price * TAX_RATE)
    this.priceTarget.valueAsNumber = newPrice
  }

  connect() {
    this.buttonTarget.addEventListener("click", this.addTax)
  }

  disconnect() {
    this.buttonTarget.removeEventListener("click", this.addTax)
  }
}
