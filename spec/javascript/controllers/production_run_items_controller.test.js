import { Application } from "@hotwired/stimulus"
import ProductionRunItemsController from "controllers/production_run_items_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))
let application

beforeEach(async () => {
  const index = '${ID}'
  document.body.innerHTML = `
    <form>
      <div data-controller="production-run-items">
        <table><tbody data-production-run-items-target="rows"></tbody></table>
        <template data-production-run-items-target="template">
          <tr>
            <td><label for="product_${index}">Product</label>
              <select id="product_${index}" name="production_run[run_items_attributes][${index}][product_id]">
                <option value=""></option><option value="12">Bread</option><option value="34">Rolls</option>
              </select>
            </td>
            <td><input name="production_run[run_items_attributes][${index}][overbake_quantity]"></td>
            <td><button type="button" data-action="production-run-items#remove">X</button></td>
          </tr>
        </template>
        <button type="button" data-action="production-run-items#add">Add Product</button>
      </div>
    </form>
  `
  application = Application.start()
  application.register("production-run-items", ProductionRunItemsController)
  await nextTick()
})

afterEach(() => application.stop())

test("adding products preserves earlier values and submits distinct nested attributes", () => {
  const rows = document.querySelector("tbody")
  expect(rows.children).toHaveLength(1)
  const firstSelect = rows.querySelector("select")
  const firstQuantity = rows.querySelector("input")
  firstSelect.value = "12"
  firstQuantity.value = "25"

  document.querySelector('[data-action="production-run-items#add"]').click()
  document.querySelector('[data-action="production-run-items#add"]').click()

  expect(rows.children).toHaveLength(3)
  expect(firstSelect.value).toBe("12")
  expect(firstQuantity.value).toBe("25")
  const selects = [...rows.querySelectorAll("select")]
  expect(new Set(selects.map(select => select.name)).size).toBe(3)
  expect(new Set(selects.map(select => select.id)).size).toBe(3)
  selects.forEach(select => expect(select.labels[0].htmlFor).toBe(select.id))
  selects[1].value = "34"
  const data = new FormData(document.querySelector("form"))
  expect(data.get(firstSelect.name)).toBe("12")
  expect(data.get(firstQuantity.name)).toBe("25")
  expect(data.get(selects[1].name)).toBe("34")
})

test("removing an added row excludes it from submission", () => {
  const row = document.querySelector("tbody tr")
  const name = row.querySelector("select").name
  row.querySelector("button").click()
  expect(document.querySelector("tbody").children).toHaveLength(0)
  expect(new FormData(document.querySelector("form")).has(name)).toBe(false)
})

test("removing a saved row marks it for destruction", () => {
  const row = document.querySelector("tbody tr")
  row.insertAdjacentHTML("beforeend", '<td><input type="hidden" name="production_run[run_items_attributes][0][_destroy]" value="false"></td>')
  row.querySelector("button").click()
  expect(row.hidden).toBe(true)
  expect(row.querySelector('input[type="hidden"]').value).toBe("1")
})

test("reconnecting after Turbo navigation preserves entered rows and allows more additions", async () => {
  const element = document.querySelector('[data-controller="production-run-items"]')
  const select = element.querySelector("tbody select")
  select.value = "12"
  element.remove()
  await nextTick()
  document.querySelector("form").append(element)
  await nextTick()

  expect(element.querySelector("tbody").children).toHaveLength(1)
  expect(select.value).toBe("12")
  element.querySelector('[data-action="production-run-items#add"]').click()
  expect(element.querySelector("tbody").children).toHaveLength(2)
  expect(select.value).toBe("12")
})
