import { Controller } from "@hotwired/stimulus"

type DrinkData = {
  id: number
  name: string
}

export default class extends Controller {
  static targets = ["button", "shuffle", "result"]

  declare readonly buttonTarget: HTMLButtonElement
  declare readonly shuffleTarget: HTMLElement
  declare readonly resultTarget: HTMLElement

  connect() {
    this.shuffleTarget.addEventListener("click", () => {
      this.pickRandomDrink().catch((error) => {
        console.error(error)
      })
    })
    this.buttonTarget.addEventListener("click", () => {
      this.pickRandomDrink().catch((error) => {
        console.error(error)
      })
    })
  }

  async pickRandomDrink(): Promise<void> {
    this.showLoadingIndicator()
    await fetch("/sakes/random")
      .then((response) => response.json())
      .then((data: DrinkData) => {
        this.displayRandomDrink(data)
      })
      .catch((error) => {
        console.error(error)
      })
  }

  displayRandomDrink(data: DrinkData) {
    this.resultTarget.innerHTML = `
      <h1><a href="/sakes/${data.id}" class="text-decoration-none">${data.name}</a></h1>
      `
  }

  showLoadingIndicator() {
    this.resultTarget.innerHTML = `<p>Loading...</p>`
  }
}
