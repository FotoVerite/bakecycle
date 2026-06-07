import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["product", "price", "type"]
  static values = {
    prices: Object,
    productTypes: Object,
  }

  connect() {
    this.productChanged()
  }

  productChanged() {
    if (!this.hasProductTarget) return

    const productId = this.productTarget.value

    if (this.hasPriceTarget && this.pricesValue[productId] !== undefined) {
      this.priceTarget.value = this.pricesValue[productId]
    }

    if (this.hasTypeTarget) {
      this.typeTarget.textContent = this.productTypesValue[productId] || ""
    }
  }
}
