import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["recipeType", "leadDaysField", "sortable"]

  connect() {
    this.typeChanged()
    if (this.hasSortableTarget) {
      this.sortable = Sortable.create(this.sortableTarget, {
        handle: ".drag-handle",
        animation: 150,
        ghostClass: "sortable-ghost",
        onEnd: () => this.updateSortIds(),
      })
    }
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
      this.sortable = null
    }
  }

  typeChanged() {
    const isDough = this.recipeTypeTarget.value === "dough"
    this.leadDaysFieldTarget.hidden = !isDough
  }

  submit() {
    this.updateSortIds()
  }

  updateSortIds() {
    this.sortableTarget
      .querySelectorAll("[data-nested-row]")
      .forEach((row, index) => {
        const input = row.querySelector("[data-sort-id]")
        if (input) input.value = index
      })
  }
}
