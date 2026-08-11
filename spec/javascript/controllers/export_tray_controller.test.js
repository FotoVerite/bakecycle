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
  jest.restoreAllMocks()
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

it("downloads the export that was just requested once it becomes ready", async () => {
  const click = jest.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {})
  list.insertAdjacentHTML("afterbegin", '<li id="tray_file_export_2" data-export-state="pending" data-auto-download="true"></li>')
  await nextTick()

  document.querySelector("#tray_file_export_2").outerHTML = `
    <li id="tray_file_export_2" data-export-state="ready">
      <a class="export-tray-item-link" href="/file_exports/2">Download</a>
    </li>
  `
  await nextTick()

  expect(click).toHaveBeenCalledTimes(1)
  expect(click.mock.instances[0].href).toContain("/file_exports/2")
})

it("does not download exports that were not requested in this page session", async () => {
  const click = jest.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {})
  list.insertAdjacentHTML("afterbegin", `
    <li id="tray_file_export_2" data-export-state="ready">
      <a class="export-tray-item-link" href="/file_exports/2">Download</a>
    </li>
  `)
  await nextTick()

  expect(click).not.toHaveBeenCalled()
})

it("does not auto-download a failed requested export", async () => {
  const click = jest.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {})
  list.insertAdjacentHTML("afterbegin", '<li id="tray_file_export_2" data-export-state="pending" data-auto-download="true"></li>')
  await nextTick()

  document.querySelector("#tray_file_export_2").outerHTML = `
    <li id="tray_file_export_2" data-export-state="failed">
      <a class="export-tray-item-link" href="/file_exports/2">Details</a>
    </li>
  `
  await nextTick()

  expect(click).not.toHaveBeenCalled()
})
