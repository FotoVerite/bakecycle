import { Controller } from "@hotwired/stimulus"

// Closes a <details>-based popover (export tray, account menu, pin-action
// menu) on outside click or Escape -- native <details> only ever closes via
// re-clicking its own <summary>, which leaves it covering the page until the
// user specifically finds their way back to that exact spot.
export default class extends Controller {
  connect() {
    this.clickOutside = this.clickOutside.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
    document.addEventListener("click", this.clickOutside)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside)
    document.removeEventListener("keydown", this.onKeydown)
  }

  clickOutside(event) {
    if (!this.element.hasAttribute("open") || this.element.contains(event.target)) return

    this.element.removeAttribute("open")
  }

  onKeydown(event) {
    if (event.key !== "Escape" || !this.element.hasAttribute("open")) return

    this.element.removeAttribute("open")
    this.element.querySelector("summary")?.focus()
  }
}
