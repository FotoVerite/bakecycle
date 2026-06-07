import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    if (this.element.tomselect) return

    const options = {
      allowEmptyOption: true,
      maxOptions: null,
      placeholder: this.element.dataset.placeholder || "",
    }

    if (this.element.multiple) {
      options.closeAfterSelect = false
      options.plugins = ["remove_button"]
    } else {
      options.closeAfterSelect = true
      options.maxItems = 1
    }

    this.tomSelect = new TomSelect(this.element, {
      ...options,
    })
  }

  disconnect() {
    if (this.tomSelect) this.tomSelect.destroy()
  }
}
