import { Controller } from "@hotwired/stimulus"

export default class RandomDrinkController extends Controller<HTMLElement> {
  static targets = ["modal", "result", "status"]

  declare readonly modalTarget: HTMLElement

  declare readonly resultTarget: HTMLElement

  declare readonly statusTarget: HTMLElement

  pick(): void {
    this.showLoadingIndicator()
    void this.fetchRandomDrink()
  }

  hideForCache(): void {
    this.modalTarget
      .querySelector<HTMLButtonElement>('[data-bs-dismiss="modal"]')
      ?.click()

    this.modalTarget.style.display = "none"
    document.body.classList.remove("modal-open")
    document.body.style.removeProperty("overflow")
    document.body.style.removeProperty("padding-right")
    document.querySelectorAll(".modal-backdrop").forEach((backdrop) => {
      backdrop.remove()
    })
  }

  private async fetchRandomDrink(): Promise<void> {
    try {
      const response = await fetch("/sakes/random", {
        headers: { Accept: "application/json" },
      })

      if (response.status === 404) {
        this.showMessage(this.element.dataset.emptyMessage ?? "")
        return
      }

      if (!response.ok) {
        throw new Error(
          `Random sake request failed: ${String(response.status)}`,
        )
      }

      const data: unknown = await response.json()
      if (
        typeof data !== "object" ||
        data === null ||
        !("html" in data) ||
        typeof data.html !== "string"
      ) {
        throw new Error("Random sake response has an invalid format")
      }

      this.resultTarget.innerHTML = data.html
      this.statusTarget.textContent = this.element.dataset.resultMessage ?? ""
    } catch (error) {
      console.error(error)
      this.showMessage(this.element.dataset.errorMessage ?? "")
    }
  }

  private showLoadingIndicator(): void {
    this.resultTarget.replaceChildren()
    const spinner = document.createElement("span")
    spinner.className = "spinner-border spinner-border-sm"
    spinner.setAttribute("aria-hidden", "true")

    const label = document.createElement("span")
    label.className = "visually-hidden"
    label.textContent = this.element.dataset.loadingMessage ?? ""

    this.statusTarget.replaceChildren(spinner, label)
  }

  private showMessage(message: string): void {
    this.resultTarget.replaceChildren()
    this.statusTarget.textContent = message
  }
}
