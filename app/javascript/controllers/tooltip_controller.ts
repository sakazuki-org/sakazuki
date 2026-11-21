import { Controller } from "@hotwired/stimulus"
import { Tooltip } from "bootstrap"

// Connects to data-controller="tooltip"
export default class TooltipController extends Controller<HTMLSpanElement> {
  private tooltip: Tooltip | null = null

  connect() {
    this.tooltip = new Tooltip(this.element)
  }

  disconnect() {
    if (this.tooltip !== null) {
      this.tooltip.dispose()
      this.tooltip = null
    }
  }
}
