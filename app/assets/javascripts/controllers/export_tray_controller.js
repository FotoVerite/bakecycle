import { Controller } from "@hotwired/stimulus"

// The header export tray keeps a quiet ready-download badge. It also makes one
// best-effort download attempt for an export started in this page session; the
// visible tray link remains the fallback if the browser blocks that attempt.
export default class extends Controller {
  static targets = ["badge", "badgeLabel", "list"]

  connect() {
    this.readyCount = 0
    this.readyIds = new Set(this.readyItems().map((li) => li.id))
    this.autoDownloadIds = new Set()
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
        if (node.nodeType !== Node.ELEMENT_NODE) continue

        if (node.dataset.autoDownload === "true") this.autoDownloadIds.add(node.id)
        if (!this.isReadyDownload(node) || this.readyIds.has(node.id)) continue

        this.readyIds.add(node.id)
        hasNewReadyDownload = true

        if (node.dataset.exportState === "failed") {
          this.autoDownloadIds.delete(node.id)
        } else if (this.autoDownloadIds.delete(node.id)) {
          this.download(node)
        }
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

  download(node) {
    // Follow Bakecycle's own download endpoint once. It reauthorizes the
    // export and creates a fresh signed S3 URL, while the visible tray link
    // remains available if the browser blocks this delayed download attempt.
    node.querySelector("a.export-tray-item-link")?.click()
  }
}
