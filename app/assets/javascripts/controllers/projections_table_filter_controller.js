import { Controller } from "@hotwired/stimulus"

// Instant client-side narrowing of the Product Projections results --
// search and category only change which already-rendered rows are visible,
// so there's nothing worth a page reload for. Regenerating the numbers
// (date range, buffers) still goes through a normal form submit.
export default class extends Controller {
  static targets = ["searchInput", "categorySelect", "row", "resultCount", "emptyState"]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.hasSearchInputTarget ? this.searchInputTarget.value.trim().toLowerCase() : ""
    const category = this.hasCategorySelectTarget ? this.categorySelectTarget.value : ""
    let visible = 0

    this.rowTargets.forEach((row) => {
      const matchesName = !query || row.dataset.productName.includes(query)
      const matchesCategory = !category || row.dataset.category === category
      const show = matchesName && matchesCategory
      row.hidden = !show
      if (show) visible += 1
    })

    if (this.hasResultCountTarget) this.resultCountTarget.textContent = visible
    if (this.hasEmptyStateTarget) this.emptyStateTarget.hidden = visible !== 0
  }
}
