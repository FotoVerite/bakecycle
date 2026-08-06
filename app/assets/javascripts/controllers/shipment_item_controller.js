import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["product", "price", "type"]
  static values = {
    prices: Object,
    productTypes: Object,
  }

  // Highlight a number cell's whole value on focus so typing replaces it,
  // rather than dropping a caret. Deferred a frame so the click's own mouseup
  // (which otherwise collapses the selection to a caret) doesn't undo it.
  selectContents(event) {
    const input = event.target
    requestAnimationFrame(() => input.select())
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
