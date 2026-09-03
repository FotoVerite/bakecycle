import { Application } from "@hotwired/stimulus"
import TomSelectController from "controllers/tom_select_controller"

const nextTick = () => new Promise(r => setTimeout(r, 0))

// One product edit form: the shared client options source set_clients renders, plus a
// price-variant row bound to one of those clients.
function renderProductForm({ sourceOptions, rowClient }) {
  document.body.innerHTML = `
    <script type="application/json" id="product-clients-options">
      ${JSON.stringify(sourceOptions)}
    </script>
    <select name="product[price_variants_attributes][0][client_id]"
            data-controller="tom-select"
            data-tom-select-options-source-value="#product-clients-options">
      <option value="">Select Client</option>
      <option value="${rowClient.value}" selected>${rowClient.text}</option>
    </select>
  `
}

const currentSelect = () => document.querySelector("select[name*='client_id']")

describe("tom_select_controller shared options source", () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register("tom-select", TomSelectController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  it("re-reads the source when a Turbo visit swaps in a different product's list", async () => {
    // The cache was keyed on the selector string, in a module that outlives the page, so
    // every product edited after the first in one Turbo session got the first product's
    // client list. A list holds the active clients plus only the inactive ones THAT
    // product references, so a row bound to an inactive client the stale list didn't
    // carry found no matching option, blanked itself, and saved client_id "" -- turning a
    // per-client price into an All Clients price.
    renderProductForm({
      sourceOptions: [{ value: "355", text: "An Active Client" }, { value: "911", text: "First Inactive" }],
      rowClient: { value: "911", text: "First Inactive" }
    })
    await nextTick()
    expect(currentSelect().value).toBe("911")

    // Turbo swaps the body: same selector, different product, different list.
    renderProductForm({
      sourceOptions: [{ value: "355", text: "An Active Client" }, { value: "722", text: "Second Inactive" }],
      rowClient: { value: "722", text: "Second Inactive" }
    })
    await nextTick()

    const select = currentSelect()
    expect(select.value).toBe("722")
    expect(select.tomselect.getItem("722")).toBeTruthy()
  })
})
