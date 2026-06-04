import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["filter", "row"]

  connect() {
    this.tomSelect = new TomSelect(this.filterTarget, {
      plugins: ["remove_button"],
      onChange: () => this.filter(),
    })
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
      this.tomSelect = null
    }
  }

  filter() {
    const raw = this.tomSelect ? this.tomSelect.getValue() : this.selectedValues()
    const ids = (Array.isArray(raw) ? raw : raw ? [raw] : []).map(Number)

    this.rowTargets.forEach(row => {
      const id = parseInt(row.dataset.ingredientId, 10)
      row.hidden = ids.length > 0 && !ids.includes(id)
    })
  }

  selectedValues() {
    return Array.from(this.filterTarget.selectedOptions).map(option => option.value)
  }
}
