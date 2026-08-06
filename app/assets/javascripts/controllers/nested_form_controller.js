import { Controller } from "@hotwired/stimulus"
import { sharedOptions } from "./tom_select_controller"

export default class extends Controller {
  static targets = ["rows", "template"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    // Flag dynamic add so handleTomSelectConnect filters once the new row's
    // tom-select instance is ready. Don't filter here -- the select has no
    // .tomselect yet.
    this.awaitingDynamicConnect = true
  }

  remove(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-nested-row]")
    const destroyInput = row.querySelector("[data-destroy-field]")
    if (destroyInput) {
      this.markRowDestroyed(row, destroyInput)
    } else {
      row.remove()
    }
  }

  restore(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-nested-row]")
    this.markRowRestored(row, row.querySelector("[data-destroy-field]"))
  }

  markRowDestroyed(row, destroyInput) {
    destroyInput.value = "1"
    row.classList.add("nested-row--destroyed")
    row.querySelectorAll(".nested-field").forEach(el => { el.disabled = true })
    row.querySelector(".nested-btn-remove").hidden = true
    row.querySelector(".nested-btn-restore").hidden = false
  }

  markRowRestored(row, destroyInput) {
    destroyInput.value = ""
    row.classList.remove("nested-row--destroyed")
    row.querySelectorAll(".nested-field").forEach(el => { el.disabled = false })
    row.querySelector(".nested-btn-remove").hidden = false
    row.querySelector(".nested-btn-restore").hidden = true
  }

  // Only ever fires for a brand-new row's tom-select (the "+ Add" flow sets
  // awaitingDynamicConnect right before this connects). Persisted rows' own
  // tom-selects are never touched by this controller at all -- previously this
  // also ran a batched resync across every row on initial page load, using a
  // row's own value as read by tom-select's asynchronously-hydrated internal
  // state to decide whether it was safe to touch. That state could still be
  // "unset" when the batch fired, making an existing row's real, already-saved
  // client look removable; stripping that option meant tom-select landed on no
  // selection at all, and the next save persisted client_id: "" over a real
  // per-client price. The dropdown-filtering it existed for is a pure UX
  // nicety anyway -- price_variants already has a hard DB unique index on
  // (quantity, product_id, client_id), so a genuine duplicate pick simply
  // can't be saved; it just now surfaces as a normal validation error instead
  // of being hidden from the dropdown in advance.
  handleTomSelectConnect() {
    if (!this.awaitingDynamicConnect) return

    this.awaitingDynamicConnect = false
    this.filterNewRowOptions()
  }

  // Hides clients already picked in other rows from the new row's own dropdown.
  // Only ever mutates this one tom-select instance -- every other row, persisted
  // or not, is read from (to know what's taken) but never written to.
  filterNewRowOptions() {
    const selects = this.getActiveSelects()
    const newSelect = selects[selects.length - 1]
    if (!newSelect || !newSelect.tomselect) return

    const sourceSelector = newSelect.dataset.tomSelectOptionsSourceValue
    if (!sourceSelector) return

    const takenElsewhere = new Set(
      selects
        .filter(select => select !== newSelect)
        .map(select => select.value)
        .filter(value => value !== "")
    )

    const ts = newSelect.tomselect
    sharedOptions(sourceSelector).forEach(option => {
      const value = String(option.value)
      const isPresent = Object.prototype.hasOwnProperty.call(ts.options, value)

      if (takenElsewhere.has(value) && isPresent) {
        ts.removeOption(value)
      } else if (!takenElsewhere.has(value) && !isPresent) {
        // Clone -- see tom_select_controller.js for why shared option objects can't
        // be handed to more than one TomSelect instance.
        ts.addOption({ ...option })
      }
    })
    ts.refreshOptions(false)
  }

  getActiveSelects() {
    const activeRows = [...this.rowsTarget.querySelectorAll("[data-nested-row]")]
      .filter(row => !row.classList.contains("nested-row--destroyed"))
    return activeRows.map(row => row.querySelector("select[name*='[client_id]']")).filter(Boolean)
  }
}
