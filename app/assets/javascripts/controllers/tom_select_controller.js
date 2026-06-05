import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    if (this.element.tomselect) return

    this.tomSelect = new TomSelect(this.element, {
      allowEmptyOption: true,
      closeAfterSelect: false,
      maxOptions: null,
      plugins: ["remove_button"],
      placeholder: this.element.dataset.placeholder || "",
    })
  }

  disconnect() {
    if (this.tomSelect) this.tomSelect.destroy()
  }
}
