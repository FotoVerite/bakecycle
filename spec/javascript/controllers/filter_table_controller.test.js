import { Application } from "@hotwired/stimulus"
import FilterTableController from "controllers/filter_table_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))

const fixture = `
  <div data-controller="filter-table">
    <input data-filter-table-target="nameInput">
    <select data-filter-table-target="statusSelect">
      <option value="current" selected>Current</option>
      <option value="lapsed">Lapsed</option>
      <option value="any">Any</option>
    </select>
    <select data-filter-table-target="activeSelect">
      <option value="true" selected>Yes</option>
      <option value="false">No</option>
      <option value="any">Any</option>
    </select>
    <a href="/clients/print_client_list?type=true" data-filter-table-target="exportLink">Export</a>
    <strong data-filter-table-target="resultCount"></strong>
    <button data-filter-table-target="resetButton" data-action="filter-table#reset">Reset filters</button>
    <div data-filter-table-target="emptyState" hidden>No clients match</div>
    <div data-filter-table-target="table">
      <div data-filter-table-target="row" data-name="Alpha Cafe" data-status="current" data-active="true" data-href="/clients/1"></div>
      <div data-filter-table-target="row" data-name="Beta Bakery" data-status="lapsed" data-active="false" data-href="/clients/2"></div>
    </div>
  </div>
`

let application
let controller

beforeEach(async () => {
  application = Application.start()
  application.register("filter-table", FilterTableController)
  document.body.innerHTML = fixture
  await nextTick()
  const element = document.querySelector("[data-controller='filter-table']")
  controller = application.getControllerForElementAndIdentifier(element, "filter-table")
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

it("reports the default filtered result count", () => {
  expect(controller.resultCountTarget.textContent).toBe("1 client")
  expect(controller.resetButtonTarget.disabled).toBe(true)
  expect(controller.emptyStateTarget.hidden).toBe(true)
  expect(controller.tableTarget.hidden).toBe(false)
})

it("shows an actionable empty state when nothing matches", () => {
  controller.nameInputTarget.value = "missing"
  controller.filter()

  expect(controller.resultCountTarget.textContent).toBe("0 clients")
  expect(controller.resetButtonTarget.disabled).toBe(false)
  expect(controller.emptyStateTarget.hidden).toBe(false)
  expect(controller.tableTarget.hidden).toBe(true)
})

it("resets to the operational default filters", () => {
  controller.nameInputTarget.value = "beta"
  controller.statusSelectTarget.value = "lapsed"
  controller.activeSelectTarget.value = "false"

  controller.reset()

  expect(controller.nameInputTarget.value).toBe("")
  expect(controller.statusSelectTarget.value).toBe("current")
  expect(controller.activeSelectTarget.value).toBe("true")
  expect(controller.resultCountTarget.textContent).toBe("1 client")
  expect(controller.resetButtonTarget.disabled).toBe(true)
  expect(document.activeElement).toBe(controller.nameInputTarget)
})
