import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Parsed once per shared <script type="application/json"> source, no matter how many
// selects on the page point at it -- see optionsSource below. Exported so
// nested_form_controller can filter the same master list per-row (already-selected
// elsewhere) without re-parsing it itself.
const sharedOptionsCache = new Map()

export function sharedOptions(sourceSelector) {
  if (!sharedOptionsCache.has(sourceSelector)) {
    const el = document.querySelector(sourceSelector)
    sharedOptionsCache.set(sourceSelector, el ? JSON.parse(el.textContent) : [])
  }
  return sharedOptionsCache.get(sourceSelector)
}

export default class extends Controller {
  static values = { optionsSource: String }

  connect() {
    if (this.element.tomselect) return

    const options = {
      allowEmptyOption: true,
      maxOptions: null,
      placeholder: this.element.dataset.placeholder || "",
    }

    // Opt-in only: a select whose full choice list is identical to other selects on the
    // page (e.g. every row in a per-client override table) can point at one shared
    // options-source id instead of each row repeating the full <option> list in HTML.
    // Selects that render their own distinct list (order items, recipes, search forms,
    // etc.) are unaffected -- they keep reading from their own <option> tags as before.
    if (this.hasOptionsSourceValue) {
      options.options = sharedOptions(this.optionsSourceValue)
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

    // Rows added later (e.g. via nested-form's "+ Add" button) connect this controller
    // asynchronously, after nested-form's own insert-then-sync call has already run --
    // so at sync time this row's .tomselect doesn't exist yet and it's skipped, ending up
    // with the full unfiltered list instead of having already-picked-elsewhere values
    // excluded. Announcing connect lets nested-form (or anything else that cares) re-sync
    // once this instance actually exists, via a plain data-action, no direct coupling.
    //
    // Deferred a microtask because for dynamically inserted rows this connect() runs
    // inside the same mutation-observer pass that hasn't yet reached the ancestor
    // controller's action bindings for the new row -- dispatching synchronously here
    // means no listener exists yet and the event is silently lost, leaving the new row
    // unfiltered. One microtask later every observer in that pass has finished.
    queueMicrotask(() => this.dispatch("connect", { bubbles: true }))
  }

  disconnect() {
    if (this.tomSelect) this.tomSelect.destroy()
  }
}
