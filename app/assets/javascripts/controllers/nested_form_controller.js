import { Controller } from "@hotwired/stimulus"
import { sharedOptions } from "./tom_select_controller"

export default class extends Controller {
  static targets = ["rows", "template"]

  connect() {
    // Count initial tom-selects and wait for all to connect before the first
    // resync. This batches 80+ syncs into 1, saving ~3s on initial page load.
    // After initial load, dynamically added rows bypass this via the flag.
    this.expectedTomSelectConnections = this.rowsTarget.querySelectorAll(
      "[data-nested-row] select[data-controller~='tom-select']"
    ).length
    this.tomSelectConnections = 0
    this.initialLoadComplete = false

    if (this.expectedTomSelectConnections === 0) {
      this.initialLoadComplete = true
      this.syncClientSelects()
    }
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    // Flag dynamic add so handleTomSelectConnect syncs when the new row's
    // tom-select instance is ready. Don't sync here—the select has no .tomselect
    // yet, so dedup wouldn't work properly for the new row anyway.
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
    this.syncClientSelects()
  }

  restore(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-nested-row]")
    this.markRowRestored(row, row.querySelector("[data-destroy-field]"))
    this.syncClientSelects()
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

  // Each row's tom-select dispatches this on connect. For initial page load,
  // batches all syncs until the last row connects (saves ~3s). For dynamically
  // added rows, syncs immediately when the new tom-select is ready.
  handleTomSelectConnect() {
    // Dynamic add: sync now that the new row's tom-select exists.
    if (this.awaitingDynamicConnect) {
      this.awaitingDynamicConnect = false
      this.syncClientSelects()
      return
    }

    // Initial page load: count connections, sync once all are in.
    if (!this.initialLoadComplete) {
      this.tomSelectConnections += 1
      if (this.tomSelectConnections < this.expectedTomSelectConnections) return
      this.initialLoadComplete = true
    }

    this.syncClientSelects()
  }

  syncClientSelects() {
    const selects = this.getActiveSelects()

    selects.forEach((select, index) => {
      // Collect values from all OTHER rows (not this one)
      const selectedInOthers = new Set(
        selects
          .filter((_, i) => i !== index)
          .map(s => s.value)
          .filter(v => v !== "")
      )

      if (select.tomselect) {
        this.syncTomSelectOptions(select, selectedInOthers)
      } else {
        select.querySelectorAll("option").forEach(opt => {
          opt.disabled = opt.value !== "" && selectedInOthers.has(opt.value)
        })
      }
    })
  }

  getActiveSelects() {
    const activeRows = [...this.rowsTarget.querySelectorAll("[data-nested-row]")]
      .filter(row => !row.classList.contains("nested-row--destroyed"))
    return activeRows.map(row => row.querySelector("select[name*='[client_id]']")).filter(Boolean)
  }

  // tom-select owns its own option list once initialized (it doesn't read back from the
  // native <select>'s <option> tags), so "already picked in another row" has to be
  // enforced by adding/removing entries from that instance's own list instead of toggling
  // .disabled on DOM nodes that no longer exist. The master list to add back from is the
  // same shared options-source cache tom_select_controller reads from, keyed off the same
  // data attribute -- so this stays in sync with whatever that select was seeded from
  // without needing its own copy of the data.
  syncTomSelectOptions(select, selectedInOthers) {
    const ts = select.tomselect
    const sourceSelector = select.dataset.tomSelectOptionsSourceValue
    if (!sourceSelector) return

    // Read the underlying native <select>'s value, not ts.getValue() -- on
    // initial page load to seed
    const ownValue = select.value

    sharedOptions(sourceSelector).forEach(option => {
      const value = String(option.value)
      // Never strip this select's own current selection -- if another row also
      // reports this value (e.g. a duplicate in-progress pick), that's the OTHER
      // row's problem to resolve, not a reason to blank out this one.
      const isTaken = selectedInOthers.has(value) && value !== ownValue
      const isPresent = Object.prototype.hasOwnProperty.call(ts.options, value)

      if (isTaken && isPresent) {
        ts.removeOption(value)
      } else if (!isTaken && !isPresent) {
        // Clone -- see tom_select_controller.js for why shared option objects can't
        // be handed to more than one TomSelect instance.
        ts.addOption({ ...option })
      }
    })
    ts.refreshOptions(false)
  }
}
