import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rows", "template"]

  connect() {
    if (!this.rowsTarget.querySelector("tr")) this.appendRow()
  }

  add(event) {
    event.preventDefault()
    this.appendRow()
  }

  appendRow() {
    this.nextId = Math.max(Date.now(), (this.nextId || 0) + 1)
    this.rowsTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.replaceAll("${ID}", this.nextId))
  }

  remove(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("tr")
    const destroyInput = row.querySelector("input[name$='[_destroy]']")

    if (destroyInput) {
      destroyInput.value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
  }
}
