import { Controller } from "@hotwired/stimulus"

// Instant visual feedback for links that trigger a synchronous server-side
// send_data download (packing slip PDF, Quickbooks IIF export) instead of the
// async ExporterJob/tray pipeline. Those never show a spinner anywhere, so
// without this the click looks like nothing happened during the round trip.
//
// Works two ways depending on what targets are present:
//   - icon target only (compact table-action-icon buttons): swap just the
//     icon glyph for a spinner, keep the surrounding tooltip/color box as-is.
//   - icon + label targets (full-size buttons): swap the icon for a spinner
//     and the label text for the loading copy.
export default class extends Controller {
  static targets = ["icon", "label"]
  static values = { label: { type: String, default: "Preparing…" } }

  connect() {
    this.defaultIconHTML = this.hasIconTarget ? this.iconTarget.innerHTML : null
    this.defaultLabelText = this.hasLabelTarget ? this.labelTarget.textContent : null
    this.handleResponse = this.handleResponse.bind(this)
  }

  disconnect() {
    this.clearListeners()
  }

  start(event) {
    if (this.element.classList.contains("is-loading")) {
      event.preventDefault()
      return
    }

    this.element.classList.add("is-loading")
    this.element.setAttribute("aria-busy", "true")

    if (this.hasIconTarget) {
      this.iconTarget.innerHTML = '<span class="sync-download-spinner" aria-hidden="true"></span>'
    }
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.labelValue
    }

    document.addEventListener("turbo:before-fetch-response", this.handleResponse, { once: true })
    // Safety net: some responses never dispatch a Turbo fetch event for this
    // click (aborted request, popup blocker, etc.) -- never leave it stuck.
    this.resetTimeout = setTimeout(() => this.reset(), 8000)
  }

  handleResponse() {
    this.reset()
  }

  reset() {
    this.clearListeners()
    this.element.classList.remove("is-loading")
    this.element.removeAttribute("aria-busy")

    if (this.hasIconTarget) this.iconTarget.innerHTML = this.defaultIconHTML
    if (this.hasLabelTarget) this.labelTarget.textContent = this.defaultLabelText
  }

  clearListeners() {
    document.removeEventListener("turbo:before-fetch-response", this.handleResponse)
    clearTimeout(this.resetTimeout)
  }
}
