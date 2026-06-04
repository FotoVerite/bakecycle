import { Controller } from "@hotwired/stimulus"

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
      select.querySelectorAll("option").forEach(opt => {
        opt.disabled = opt.value !== "" && opt.value !== select.value && selected.has(opt.value)
      })
    })
  }
}
