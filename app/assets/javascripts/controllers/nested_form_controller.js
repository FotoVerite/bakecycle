import { Controller } from "@hotwired/stimulus"
import { sharedOptions } from "./tom_select_controller"

export default class extends Controller {
  static targets = ["rows", "template"]

  connect() {
    this.syncClientSelects()
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    this.syncClientSelects()
  }

  remove(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-nested-row]")
    const destroyInput = row.querySelector("[data-destroy-field]")
    if (destroyInput) {
      destroyInput.value = "1"
      row.classList.add("nested-row--destroyed")
      row.querySelectorAll(".nested-field").forEach(el => { el.disabled = true })
      row.querySelector(".nested-btn-remove").hidden = true
      row.querySelector(".nested-btn-restore").hidden = false
    } else {
      row.remove()
    }
    this.syncClientSelects()
  }

  restore(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-nested-row]")
    const destroyInput = row.querySelector("[data-destroy-field]")
    destroyInput.value = ""
    row.classList.remove("nested-row--destroyed")
    row.querySelectorAll(".nested-field").forEach(el => { el.disabled = false })
    row.querySelector(".nested-btn-remove").hidden = false
    row.querySelector(".nested-btn-restore").hidden = true
    this.syncClientSelects()
  }

  syncClientSelects() {
    const activeRows = [...this.rowsTarget.querySelectorAll("[data-nested-row]")]
      .filter(row => !row.classList.contains("nested-row--destroyed"))
    const selects = activeRows.map(row => row.querySelector("select[name*='[client_id]']")).filter(Boolean)
    const selected = new Set(selects.map(s => s.value).filter(v => v !== ""))

    selects.forEach(select => {
      if (select.tomselect) {
        this.syncTomSelectOptions(select, selected)
      } else {
        select.querySelectorAll("option").forEach(opt => {
          opt.disabled = opt.value !== "" && opt.value !== select.value && selected.has(opt.value)
        })
      }
    })
  }

  // tom-select owns its own option list once initialized (it doesn't read back from the
  // native <select>'s <option> tags), so "already picked in another row" has to be
  // enforced by adding/removing entries from that instance's own list instead of toggling
  // .disabled on DOM nodes that no longer exist. The master list to add back from is the
  // same shared options-source cache tom_select_controller reads from, keyed off the same
  // data attribute -- so this stays in sync with whatever that select was seeded from
  // without needing its own copy of the data.
  syncTomSelectOptions(select, selectedElsewhere) {
    const ts = select.tomselect
    const sourceSelector = select.dataset.tomSelectOptionsSourceValue
    if (!sourceSelector) return

    const ownValue = String(select.value)
    sharedOptions(sourceSelector).forEach(option => {
      const value = String(option.value)
      const isTakenElsewhere = value !== ownValue && selectedElsewhere.has(value)
      const isPresent = Object.prototype.hasOwnProperty.call(ts.options, value)

      if (isTakenElsewhere && isPresent) {
        ts.removeOption(value)
      } else if (!isTakenElsewhere && !isPresent) {
        ts.addOption(option)
      }
    })
    ts.refreshOptions(false)
  }
}
