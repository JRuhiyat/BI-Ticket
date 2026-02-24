import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._handler = this._onClick.bind(this)
    document.addEventListener("click", this._handler)
    this.element.setAttribute("role", "list")
  }

  disconnect() {
    document.removeEventListener("click", this._handler)
  }

  _onClick(event) {
    // common legend item selectors across chart libs
    const selector = [
      "li",
      ".chartkick-legend li",
      ".chart-legend li",
      ".chart-legend-item",
      ".chartkick-legend-item",
      ".legend-item",
      "[data-legend-item]"
    ].join(",")

    const item = event.target.closest(selector)
    if (!item) return
    // only toggle if the clicked legend is inside this controller's container
    if (!this.element.contains(item)) return

    const li = item.tagName === "LI" ? item : (item.closest("li") || item)
    li.classList.toggle("strike")
    li.setAttribute("aria-pressed", li.classList.contains("strike"))
  }
}