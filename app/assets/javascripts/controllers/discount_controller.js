import { Controller } from "@hotwired/stimulus"

// Keeps the discount value field and live preview in sync with the selected
// discount type. Read-only (not disabled) when "No discount" is chosen --
// a disabled field is omitted from form submission entirely, which would
// leave the old value untouched in the database; `readonly` still submits
// the (now empty) value, so the server sees an unambiguous "no discount"
// instead of a paired type/value validation error.
//
// The preview only takes up space once there's something to preview --
// before that, "No discount" already says everything the empty preview
// card would have repeated.
export default class extends Controller {
  static targets = ["typeInput", "valueField", "valueInput", "entryRow", "preview", "previewValue"]
  static values = { baseAmount: Number }

  connect() {
    this.sync()
  }

  sync() {
    const checked = this.typeInputTargets.find(input => input.checked)
    const type = checked ? checked.value : ""
    const hasType = !!type

    this.valueInputTarget.readOnly = !hasType
    this.valueFieldTarget.classList.toggle("discount-value-field--disabled", !hasType)
    if (!hasType) this.valueInputTarget.value = ""

    this.updatePreview(type)
  }

  updatePreview(type) {
    if (!this.hasPreviewTarget) return

    const value = parseFloat(this.valueInputTarget.value)
    const active = !!type && !Number.isNaN(value) && value > 0

    this.entryRowTarget.classList.toggle("discount-entry-row--solo", !active)
    this.previewTarget.classList.toggle("is-active", active)
    this.previewTarget.classList.toggle("discount-preview--hidden", !active)

    if (!active) return

    const formatted = this.formatPreview(type, value)
    if (this.previewValueTarget.textContent === formatted) return

    // Quick fade so an updated number reads as "this just changed", not a
    // jarring instant swap -- the one delight moment in this form, kept to
    // the < 1s the product register asks for.
    this.previewValueTarget.classList.add("discount-preview-value--updating")
    requestAnimationFrame(() => {
      this.previewValueTarget.textContent = formatted
      this.previewValueTarget.classList.remove("discount-preview-value--updating")
    })
  }

  formatPreview(type, value) {
    if (type === "percentage" && this.hasBaseAmountValue) {
      return this.currency((this.baseAmountValue * value) / 100)
    }

    if (type === "percentage") {
      return `${this.trimZeros(value)}%`
    }

    return this.currency(value)
  }

  currency(amount) {
    return `$${amount.toFixed(2)}`
  }

  trimZeros(value) {
    return String(parseFloat(value.toFixed(2)))
  }
}
