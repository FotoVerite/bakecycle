import { Application } from "@hotwired/stimulus"
import FilterTableController from "controllers/filter_table_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))

const fixture = `
  <div data-controller="filter-table">
    <form data-filter-table-target="form">
      <input data-filter-table-target="nameInput" name="filter[name]">
      <select data-filter-table-target="statusSelect" name="filter[status]">
        <option value="current" selected>Current</option>
        <option value="lapsed">Lapsed</option>
        <option value="any">Any</option>
      </select>
      <select data-filter-table-target="activeSelect" name="filter[active]">
        <option value="true" selected>Yes</option>
        <option value="false">No</option>
        <option value="any">Any</option>
      </select>
    </form>
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
  document.querySelector("form").requestSubmit = jest.fn()
  await nextTick()
  const element = document.querySelector("[data-controller='filter-table']")
  controller = application.getControllerForElementAndIdentifier(element, "filter-table")
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

it("sets default control state without scanning rows", () => {
  expect(controller.resetButtonTarget.disabled).toBe(true)
  expect(controller.formTarget.requestSubmit).not.toHaveBeenCalled()
})

it("submits the form when select filters change", () => {
  controller.statusSelectTarget.value = "lapsed"

  controller.filter()

  expect(controller.resetButtonTarget.disabled).toBe(false)
  expect(controller.formTarget.requestSubmit).toHaveBeenCalledTimes(1)
})

it("debounces text filter submissions", async () => {
  jest.useFakeTimers()
  controller.nameInputTarget.value = "alpha"

  controller.scheduleSubmit()
  controller.scheduleSubmit()
  jest.advanceTimersByTime(249)
  expect(controller.formTarget.requestSubmit).not.toHaveBeenCalled()

  jest.advanceTimersByTime(1)
  expect(controller.formTarget.requestSubmit).toHaveBeenCalledTimes(1)
  jest.useRealTimers()
})

it("submits immediately on enter when there are multiple rendered rows", () => {
  const event = { key: "Enter", preventDefault: jest.fn() }
  controller.navigateIfOne(event)

  expect(event.preventDefault).toHaveBeenCalledTimes(1)
  expect(controller.formTarget.requestSubmit).toHaveBeenCalledTimes(1)
})

it("resets to the operational default filters", () => {
  controller.nameInputTarget.value = "beta"
  controller.statusSelectTarget.value = "lapsed"
  controller.activeSelectTarget.value = "false"

  controller.reset()

  expect(controller.nameInputTarget.value).toBe("")
  expect(controller.statusSelectTarget.value).toBe("current")
  expect(controller.activeSelectTarget.value).toBe("true")
  expect(controller.resetButtonTarget.disabled).toBe(true)
  expect(controller.formTarget.requestSubmit).toHaveBeenCalledTimes(1)
})
