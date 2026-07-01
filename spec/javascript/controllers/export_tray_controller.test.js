import { Application } from "@hotwired/stimulus"
import ExportTrayController from "controllers/export_tray_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))

const fixture = `
  <details data-controller="export-tray" data-action="toggle->export-tray#toggled">
    <summary>
      <span data-export-tray-target="badge" hidden>0</span>
      <span data-export-tray-target="badgeLabel">No ready downloads</span>
    </summary>
    <ul data-export-tray-target="list">
      <li id="tray_file_export_1" data-export-state="pending"></li>
    </ul>
  </details>
`

let application
let element
let list
let badge
let badgeLabel

beforeEach(async () => {
  application = Application.start()
  application.register("export-tray", ExportTrayController)
  document.body.innerHTML = fixture
  await nextTick()

  element = document.querySelector("[data-controller='export-tray']")
  list = document.querySelector("[data-export-tray-target='list']")
  badge = document.querySelector("[data-export-tray-target='badge']")
  badgeLabel = document.querySelector("[data-export-tray-target='badgeLabel']")
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

it("does not badge newly queued exports", async () => {
  list.insertAdjacentHTML("afterbegin", '<li id="tray_file_export_2" data-export-state="pending"></li>')
  await nextTick()

  expect(badge.hidden).toBe(true)
  expect(badge.textContent).toBe("0")
  expect(badgeLabel.textContent).toBe("No ready downloads")
})

it("badges exports that become ready while the tray is closed", async () => {
  list.insertAdjacentHTML("afterbegin", '<li id="tray_file_export_1" data-export-state="ready"></li>')
  await nextTick()

  expect(badge.hidden).toBe(false)
  expect(badge.textContent).toBe("1")
  expect(badgeLabel.textContent).toBe("1 ready download")
})

it("counts failed exports as ready downloads that need attention", async () => {
  list.insertAdjacentHTML("afterbegin", '<li id="tray_file_export_2" data-export-state="failed"></li>')
  await nextTick()

  expect(badge.hidden).toBe(false)
  expect(badge.textContent).toBe("1")
  expect(badgeLabel.textContent).toBe("1 ready download")
})

it("clears the ready badge when opened", async () => {
  list.insertAdjacentHTML("afterbegin", '<li id="tray_file_export_2" data-export-state="ready"></li>')
  await nextTick()

  element.setAttribute("open", "")
  element.dispatchEvent(new Event("toggle"))

  expect(badge.hidden).toBe(true)
  expect(badgeLabel.textContent).toBe("No ready downloads")
})
