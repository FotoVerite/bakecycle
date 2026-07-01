import { Application } from "@hotwired/stimulus"
import ReportRangeController from "controllers/report_range_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))

const fixture = `
  <form data-controller="report-range">
    <input type="text" value="2026-06-03" data-report-range-target="start">
    <input type="text" value="2026-06-09" data-report-range-target="end">
    <button type="button" data-days="9" data-action="report-range#setDays">10 days</button>
  </form>
`

let application
let end
let preset

beforeEach(async () => {
  application = Application.start()
  application.register("report-range", ReportRangeController)
  document.body.innerHTML = fixture
  await nextTick()

  end = document.querySelector("[data-report-range-target='end']")
  preset = document.querySelector("button")
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

it("sets the end date from the start date and selected day span", () => {
  preset.click()

  expect(end.value).toBe("2026-06-12")
})
