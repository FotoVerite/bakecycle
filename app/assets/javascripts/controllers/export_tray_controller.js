import { Controller } from "@hotwired/stimulus"

// Passive unread-count badge for the header export tray. No proactive toast/
// notification -- just a quiet nudge that something finished while the tray was
// closed. In-memory only (resets on page load), no server-side read tracking.
export default class extends Controller {
  static targets = ["badge", "list"]

  connect() {
    this.unreadCount = 0
    // An export's row is prepended once (queued) then replaced in place as
    // it changes state (ready/failed) -- track which ids we've already seen
    // so a later replace of a known row doesn't get counted as a second
    // "new" export arriving.
    this.seenIds = new Set(Array.from(this.listTarget.children).map((li) => li.id))
    this.observer = new MutationObserver((mutations) => this.onMutations(mutations))
    this.observer.observe(this.listTarget, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  onMutations(mutations) {
    let hasNewArrival = false

    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE || this.seenIds.has(node.id)) continue

        this.seenIds.add(node.id)
        hasNewArrival = true
      }
    }

    if (!hasNewArrival || this.element.hasAttribute("open")) return

    this.unreadCount += 1
    this.badgeTarget.textContent = this.unreadCount
    this.badgeTarget.hidden = false

    // Restart the pop animation even if the badge was already visible.
    this.badgeTarget.classList.remove("export-tray-badge--pop")
    void this.badgeTarget.offsetWidth
    this.badgeTarget.classList.add("export-tray-badge--pop")
  }

  toggled() {
    if (this.element.hasAttribute("open")) {
      this.unreadCount = 0
      this.badgeTarget.hidden = true
    }
  }
}
