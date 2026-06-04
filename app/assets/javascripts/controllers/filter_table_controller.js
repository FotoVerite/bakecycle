import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "nameInput", "statusSelect", "activeSelect", "exportLink"]

  connect() {
    this.filter()
  }

  filter() {
    const name = this.nameInputTarget.value.toLowerCase()
    const status = this.statusSelectTarget.value
    const active = this.activeSelectTarget.value

    const visibleRows = []
    this.rowTargets.forEach(row => {
      const visible =
        this.fuzzyMatch(row.dataset.name.toLowerCase(), name) &&
        (status === "any" || row.dataset.status === status) &&
        (active === "any" || row.dataset.active === active)
      row.hidden = !visible
      if (visible) visibleRows.push(row)
    })

    this._visibleRows = visibleRows

    if (this.hasExportLinkTarget) {
      const url = new URL(this.exportLinkTarget.href, window.location.origin)
      url.searchParams.set("type", active)
      this.exportLinkTarget.href = url.toString()
    }
  }

  navigateIfOne(event) {
    if (event.key !== "Enter") return
    const rows = this._visibleRows || []
    if (rows.length === 1) {
      event.preventDefault()
      window.location.href = rows[0].dataset.href
    }
  }

  fuzzyMatch(text, search) {
    if (!search) return true
    let pos = 0
    for (const char of search.replace(/\s/g, "")) {
      const idx = text.indexOf(char, pos)
      if (idx === -1) return false
      pos = idx + 1
    }
    return true
  }
}
