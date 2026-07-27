import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rows", "template"]

  connect() {
    this.template = this.templateTarget.outerHTML.replace(
      ' data-production-run-items-target="template"',
      ""
    )
    this.templateTarget.remove()
  }

  add(event) {
    event.preventDefault()
    const id = `${Date.now()}${Math.floor(Math.random() * 1000)}`
    this.rowsTarget.insertAdjacentHTML("beforeend", this.template.replaceAll("${ID}", id))
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
