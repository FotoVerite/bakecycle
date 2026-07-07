import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "row",
    "nameInput",
    "statusSelect",
    "activeSelect",
    "exportLink",
    "resultCount",
    "resetButton",
    "emptyState",
    "table"
  ]

  connect() {
    this.updateControls()
  }

  filter() {
    this.updateControls()
    clearTimeout(this.submitTimer)
    this.submit()
  }

  scheduleSubmit() {
    this.updateControls()
    clearTimeout(this.submitTimer)
    this.submitTimer = setTimeout(() => this.submit(), 250)
  }

  disconnect() {
    clearTimeout(this.submitTimer)
  }

  submit() {
    if (!this.hasFormTarget) return

    if (this.formTarget.requestSubmit) {
      this.formTarget.requestSubmit()
    } else {
      this.formTarget.submit()
    }
  }

  updateControls() {
    const name = this.nameInputTarget.value.toLowerCase()
    const status = this.statusSelectTarget.value
    const active = this.activeSelectTarget.value

    if (this.hasExportLinkTarget) {
      const url = new URL(this.exportLinkTarget.href, window.location.origin)
      url.searchParams.set("type", active)
      this.exportLinkTarget.href = url.toString()
    }

    if (this.hasResetButtonTarget) {
      this.resetButtonTarget.disabled = name.trim() === "" && status === "current" && active === "true"
    }
  }

  reset() {
    clearTimeout(this.submitTimer)
    this.nameInputTarget.value = ""
    this.statusSelectTarget.value = "current"
    this.activeSelectTarget.value = "true"
    this.updateControls()
    this.submit()
  }

  navigateIfOne(event) {
    if (event.key !== "Enter") return
    const rows = this.rowTargets || []
    if (rows.length === 1) {
      event.preventDefault()
      window.location.href = rows[0].dataset.href
    } else {
      event.preventDefault()
      this.filter()
    }
  }
}
