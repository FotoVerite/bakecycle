import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dirty", "updatedAt", "cost", "conversion", "currentAmount", "costPerGram", "conversionToGrams"]

  change() {
    if (this.hasDirtyTarget) this.dirtyTarget.value = "true"
    if (this.hasUpdatedAtTarget) this.updatedAtTarget.value = new Date().toUTCString()
    this.updateComputed()
  }

  updateComputed() {
    const cost = parseFloat(this.hasCostTarget ? this.costTarget.value : 0) || 0
    const conversion = parseFloat(this.hasConversionTarget ? this.conversionTarget.value : 0) || 1

    if (this.hasCostPerGramTarget) {
      this.costPerGramTarget.value = conversion !== 0 ? (cost / conversion).toFixed(4) : "0.0000"
    }

    if (this.hasConversionToGramsTarget && this.hasCurrentAmountTarget) {
      const amount = parseFloat(this.currentAmountTarget.value) || 0
      this.conversionToGramsTarget.value = Math.round(amount * conversion)
    }
  }
}
