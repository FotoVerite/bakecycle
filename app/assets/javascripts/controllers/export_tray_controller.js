import { Controller } from "@hotwired/stimulus"

// Passive ready-download badge for the header export tray. No proactive toast/
// notification -- just a quiet nudge that a download finished (or failed) while
// the tray was closed. In-memory only (resets on page load), no server-side read
// tracking.
export default class extends Controller {
  static targets = ["badge", "badgeLabel", "list"]

  connect() {
    this.readyCount = 0
    this.readyIds = new Set(this.readyItems().map((li) => li.id))
    this.observer = new MutationObserver((mutations) => this.onMutations(mutations))
    this.observer.observe(this.listTarget, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  onMutations(mutations) {
    let hasNewReadyDownload = false

    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE || !this.isReadyDownload(node) || this.readyIds.has(node.id)) continue

        this.readyIds.add(node.id)
        hasNewReadyDownload = true
      }
    }

    if (!hasNewReadyDownload || this.element.hasAttribute("open")) return

    this.readyCount += 1
    this.badgeTarget.textContent = this.readyCount
    this.badgeLabelTarget.textContent = `${this.readyCount} ready ${this.readyCount === 1 ? "download" : "downloads"}`
    this.badgeTarget.hidden = false

    // Restart the pop animation even if the badge was already visible.
    this.badgeTarget.classList.remove("export-tray-badge--pop")
    void this.badgeTarget.offsetWidth
    this.badgeTarget.classList.add("export-tray-badge--pop")
  }

  toggled() {
    if (this.element.hasAttribute("open")) {
      this.readyCount = 0
      this.badgeTarget.hidden = true
      this.badgeLabelTarget.textContent = "No ready downloads"
    }
  }

  readyItems() {
    return Array.from(this.listTarget.children).filter((li) => this.isReadyDownload(li))
  }

  isReadyDownload(node) {
    return ["ready", "failed"].includes(node.dataset?.exportState)
  }
}
