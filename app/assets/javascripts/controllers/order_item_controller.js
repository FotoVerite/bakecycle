import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["product"]

  connect() {
    if (this.hasProductTarget && !this.productTarget.tomselect) {
      new TomSelect(this.productTarget, {
        allowEmptyOption: true,
        maxOptions: null,
      })
    }
  }

  disconnect() {
    if (this.hasProductTarget && this.productTarget.tomselect) {
      this.productTarget.tomselect.destroy()
    }
  }
}
