import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Parsed once per shared <script type="application/json"> source, no matter how many
// selects on the page point at it -- see optionsSource below. Exported so
// nested_form_controller can filter the same master list per-row (already-selected
// elsewhere) without re-parsing it itself.
//
// Keyed on the <script> NODE, not on the selector string: this module outlives any one
// page under Turbo Drive, so a selector key served the first product's client list to
// every product edited after it in the same visit. Each list is the active clients plus
// only the inactive clients THAT product references, so a stale list still looked
// plausible while missing the inactive clients of the product actually on screen --
// their rows found no matching option, blanked, and saved client_id "", turning a
// per-client price into an All Clients price.
const sharedOptionsCache = new WeakMap()

export function sharedOptions(sourceSelector) {
  const el = document.querySelector(sourceSelector)
  if (!el) return []

  if (!sharedOptionsCache.has(el)) {
    sharedOptionsCache.set(el, JSON.parse(el.textContent))
  }
  return sharedOptionsCache.get(el)
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
      // Clone -- tom-select mutates the option objects it's given as part of managing
      // its own instance state. Handing the same cached objects to multiple instances
      // (one per row) lets one instance's internal bookkeeping corrupt another's,
      // silently clearing an unrelated row's selection.
      options.options = sharedOptions(this.optionsSourceValue).map(option => ({ ...option }))
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
