import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inclusionable", "typeDisplay", "leadDaysDisplay"]

  connect() {
    this.updateDisplay()
  }

  selectIngredient() {
    this.updateDisplay()
  }

  updateDisplay() {
    if (!this.hasInclusionableTarget) return
    const opt = this.inclusionableTarget.selectedOptions[0]
    if (!opt || !opt.value) return
    if (this.hasTypeDisplayTarget) this.typeDisplayTarget.value = opt.dataset.type || ""
    if (this.hasLeadDaysDisplayTarget) this.leadDaysDisplayTarget.value = opt.dataset.leadDays || ""
  }
}
