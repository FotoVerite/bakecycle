import { Controller } from "@hotwired/stimulus"
import { awaitTurboResponse } from "../turbo_response_await"

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
  }

  disconnect() {
    this.cancelAwait?.()
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

    this.cancelAwait = awaitTurboResponse(() => this.reset())
  }

  reset() {
    this.element.classList.remove("is-loading")
    this.element.removeAttribute("aria-busy")

    if (this.hasIconTarget) this.iconTarget.innerHTML = this.defaultIconHTML
    if (this.hasLabelTarget) this.labelTarget.textContent = this.defaultLabelText
  }
}
