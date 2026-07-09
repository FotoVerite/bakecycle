import { Application } from "@hotwired/stimulus"
import NestedFormController from "controllers/nested_form_controller"
import TomSelectController from "controllers/tom_select_controller"

const nextTick = () => new Promise(r => setTimeout(r, 0))

// Two independent nested-form fieldsets (mirrors price_variants + bake_lead_day_variants
// on the product edit form) sharing one client options source, each with one existing
// row already bound to client "33036".
function buildFixture() {
  document.body.innerHTML = `
    <script type="application/json" id="clients-options">
      [{"value":"33036","text":"Client A"},{"value":"99999","text":"Client B"}]
    </script>

    <fieldset data-controller="nested-form" id="section-a">
      <div data-nested-form-target="rows">
        <div data-nested-row>
          <select name="a[0][client_id]" data-controller="tom-select"
                  data-tom-select-options-source-value="#clients-options"
                  data-action="change->nested-form#syncClientSelects tom-select:connect->nested-form#handleTomSelectConnect">
            <option value="">Select Client</option>
            <option value="33036" selected>Client A</option>
          </select>
        </div>
      </div>
      <template data-nested-form-target="template">
        <div data-nested-row>
          <select name="a[NEW_RECORD][client_id]" data-controller="tom-select"
                  data-tom-select-options-source-value="#clients-options"
                  data-action="change->nested-form#syncClientSelects tom-select:connect->nested-form#handleTomSelectConnect">
            <option value="">Select Client</option>
          </select>
        </div>
      </template>
      <button type="button" data-action="nested-form#add">+ Add</button>
    </fieldset>

    <fieldset data-controller="nested-form" id="section-b">
      <div data-nested-form-target="rows"></div>
      <template data-nested-form-target="template">
        <div data-nested-row>
          <select name="b[NEW_RECORD][client_id]" data-controller="tom-select"
                  data-tom-select-options-source-value="#clients-options"
                  data-action="change->nested-form#syncClientSelects tom-select:connect->nested-form#handleTomSelectConnect">
            <option value="">Select Client</option>
          </select>
        </div>
      </template>
      <button type="button" data-action="nested-form#add">+ Add</button>
    </fieldset>
  `
}

let application

beforeEach(() => {
  buildFixture()
  application = Application.start()
  application.register("nested-form", NestedFormController)
  application.register("tom-select", TomSelectController)
})

afterEach(() => {
  application.stop()
})

test("selecting a client in one fieldset's new row does not clear the same client already selected in a different fieldset", async () => {
  await nextTick()

  const sectionA = document.querySelector("#section-a")
  const sectionB = document.querySelector("#section-b")

  const rowASelect = sectionA.querySelector("select")
  expect(rowASelect.tomselect.getValue()).toBe("33036")

  // Add a new row in section B and pick the SAME client already used in section A.
  sectionB.querySelector("[data-action='nested-form#add']").click()
  await nextTick()

  const rowBSelect = sectionB.querySelector("[data-nested-row] select")
  rowBSelect.tomselect.setValue("33036")
  await nextTick()

  expect(rowBSelect.tomselect.getValue()).toBe("33036")

  // The pre-existing selection in the OTHER fieldset must survive untouched.
  expect(rowASelect.tomselect.getValue()).toBe("33036")
  expect(rowASelect.value).toBe("33036")
})
