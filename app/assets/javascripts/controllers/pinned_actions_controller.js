import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list", "status"]
  static values = { url: String }

  connect() {
    if (this.hasListTarget) {
      this.lastConfirmedOrder = this.currentRows()

      this.sortable = Sortable.create(this.listTarget, {
        handle: ".drag-handle",
        animation: 150,
        ghostClass: "sortable-ghost",
        onEnd: () => {
          this.updateMoveButtons()
          this.persistOrder()
        },
      })
    }
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
      this.sortable = null
    }

    clearTimeout(this.statusTimeout)
  }

  moveUp(event) {
    const row = event.target.closest("[data-pin-id]")
    const previous = row.previousElementSibling
    if (!previous) return

    row.parentNode.insertBefore(row, previous)
    row.querySelector(".drag-handle")?.focus()
    this.updateMoveButtons()
    this.persistOrder()
  }

  moveDown(event) {
    const row = event.target.closest("[data-pin-id]")
    const next = row.nextElementSibling
    if (!next) return

    row.parentNode.insertBefore(next, row)
    row.querySelector(".drag-handle")?.focus()
    this.updateMoveButtons()
    this.persistOrder()
  }

  currentRows() {
    return Array.from(this.listTarget.querySelectorAll("[data-pin-id]"))
  }

  updateMoveButtons() {
    const rows = this.currentRows()

    rows.forEach((row, index) => {
      const [upButton, downButton] = row.querySelectorAll(".pinned-action-move")
      if (upButton) upButton.disabled = index === 0
      if (downButton) downButton.disabled = index === rows.length - 1
    })
  }

  persistOrder() {
    const attemptedOrder = this.currentRows()
    const ids = attemptedOrder.map(row => row.dataset.pinId)

    this.setStatus("Saving order…")

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        Accept: "application/json",
      },
      body: JSON.stringify({ ordered_ids: ids }),
    })
      .then(response => {
        if (!response.ok) throw new Error(`Request failed: ${response.status}`)

        this.lastConfirmedOrder = attemptedOrder
        this.setStatus("Order saved.")
        clearTimeout(this.statusTimeout)
        this.statusTimeout = setTimeout(() => this.setStatus(""), 2000)
      })
      .catch(() => {
        this.lastConfirmedOrder.forEach(row => this.listTarget.appendChild(row))
        this.updateMoveButtons()
        this.setStatus("Couldn't save the new order. Try again.", true)
      })
  }

  setStatus(message, isError = false) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("pinned-actions-status--error", isError)
  }
}
