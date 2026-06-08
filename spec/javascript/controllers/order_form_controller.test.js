import { Application } from "@hotwired/stimulus"
import OrderFormController from "controllers/order_form_controller"

// ─── Helpers ─────────────────────────────────────────────────────────────────

const nextTick = () => new Promise(r => setTimeout(r, 0))

// Subclass Date so new Date() returns a fixed "now" without breaking setTimeout
function mockDate(fixedISOString) {
  const OriginalDate = globalThis.Date
  const fixed = new OriginalDate(fixedISOString)

  class MockDate extends OriginalDate {
    constructor(...args) {
      if (args.length === 0) super(fixed.getTime())
      else super(...args)
    }
    static now() { return fixed.getTime() }
  }

  globalThis.Date = MockDate
  return () => { globalThis.Date = OriginalDate }
}

// Minimal fixture HTML that covers every controller target.
// rows: [{ productId, leadDays, selected, destroyed }]
// dayInputs: [{ day, value }]  (data-order-item-day attributes)
function buildFixture({
  orderType  = "standing",
  startDate  = "",
  endDate    = "",
  orderId    = 0,
  kickoff    = "06:00",
  rows       = [],
  dayInputs  = [],
} = {}) {
  const rowsHtml = rows.map(({ productId = "1", leadDays = 0, selected = true, destroyed = false }) => `
    <div data-order-item-row${destroyed ? ' class="nested-row--destroyed"' : ""}>
      <select data-order-item-target="product">
        <option value="">Select...</option>
        <option value="${productId}" data-lead-days="${leadDays}"${selected ? " selected" : ""}>
          Product ${productId}
        </option>
      </select>
    </div>
  `).join("")

  const dayHtml = dayInputs.map(({ day, value = "1" }) => `
    <input data-order-item-day="${day}" type="number" value="${value}">
  `).join("")

  return `
    <div
      data-controller="order-form"
      data-order-form-kickoff-value="${kickoff}"
      data-order-form-order-id-value="${orderId}"
    >
      <label>
        <input type="radio" name="type" data-order-form-target="orderType"
               value="standing" ${orderType === "standing" ? "checked" : ""}>
        Standing
      </label>
      <label>
        <input type="radio" name="type" data-order-form-target="orderType"
               value="temporary" ${orderType === "temporary" ? "checked" : ""}>
        Temporary
      </label>

      <div data-order-form-target="startDateField">
        <input data-order-form-target="startDate" type="date" value="${startDate}">
        <span data-order-form-target="startDateWarning" hidden></span>
      </div>

      <div data-order-form-target="endDateField">
        <input type="date" value="${endDate}">
        <span data-order-form-target="endDateWarning" hidden></span>
      </div>

      <span data-order-form-target="leadDaysDisplay">0</span>
      <span data-order-form-target="actionWarning" hidden></span>
      <button data-order-form-target="submitBtn">Submit</button>

      ${rowsHtml}
      ${dayHtml}
    </div>
  `
}

// ─── Setup / teardown ─────────────────────────────────────────────────────────

let application

beforeEach(() => {
  application = Application.start()
  application.register("order-form", OrderFormController)
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

async function mount(opts) {
  document.body.innerHTML = buildFixture(opts)
  await nextTick()
  const el = document.querySelector("[data-controller='order-form']")
  return application.getControllerForElementAndIdentifier(el, "order-form")
}

// ─── getMaxLeadDays ───────────────────────────────────────────────────────────

describe("getMaxLeadDays", () => {
  it("returns 0 when there are no rows", async () => {
    const ctrl = await mount()
    expect(ctrl.getMaxLeadDays()).toBe(0)
  })

  it("returns the lead days from a single selected row", async () => {
    const ctrl = await mount({ rows: [{ productId: "1", leadDays: 3 }] })
    expect(ctrl.getMaxLeadDays()).toBe(3)
  })

  it("returns the maximum across multiple rows", async () => {
    const ctrl = await mount({
      rows: [
        { productId: "1", leadDays: 2 },
        { productId: "2", leadDays: 5 },
        { productId: "3", leadDays: 1 },
      ],
    })
    expect(ctrl.getMaxLeadDays()).toBe(5)
  })

  it("ignores rows marked as destroyed", async () => {
    const ctrl = await mount({
      rows: [
        { productId: "1", leadDays: 2 },
        { productId: "2", leadDays: 7, destroyed: true },
      ],
    })
    expect(ctrl.getMaxLeadDays()).toBe(2)
  })

  it("ignores rows with no product selected", async () => {
    const ctrl = await mount({ rows: [{ productId: "", leadDays: 4, selected: false }] })
    expect(ctrl.getMaxLeadDays()).toBe(0)
  })
})

// ─── updateLeadDays ───────────────────────────────────────────────────────────

describe("updateLeadDays", () => {
  it("updates the lead days display when called after rows are present", async () => {
    const ctrl = await mount({ rows: [{ productId: "1", leadDays: 4 }] })
    ctrl.updateLeadDays()
    const display = document.querySelector("[data-order-form-target='leadDaysDisplay']")
    expect(display.textContent).toBe("4")
  })
})

// ─── validateLeadTime ─────────────────────────────────────────────────────────
//
// Fixed "now": 2026-06-07 07:00:00 (Sunday, after kickoff at 06:05)
// kickoff = "06:00"  →  isBeforeKickoff = false
// neededLeadDays = maxLeadDays + 1
// mustStartAfter  = midnight of 2026-06-07 + neededLeadDays

describe("validateLeadTime", () => {
  let restoreDate

  beforeEach(() => {
    restoreDate = mockDate("2026-06-07T07:00:00")
  })

  afterEach(() => restoreDate())

  it("returns null for an existing standing order (skip validation)", async () => {
    // orderId > 0 + standing → exempt
    const ctrl = await mount({ orderId: 42, orderType: "standing", startDate: "2026-06-08" })
    expect(ctrl.validateLeadTime()).toBeNull()
  })

  it("returns null when no start date is set", async () => {
    const ctrl = await mount({ startDate: "" })
    expect(ctrl.validateLeadTime()).toBeNull()
  })

  it("returns null when start date meets the required lead days (after kickoff, 2 lead days → need +3)", async () => {
    // 2 lead days, after kickoff → need 3 days out → earliest = 2026-06-10
    const ctrl = await mount({
      startDate: "2026-06-10",
      rows: [{ productId: "1", leadDays: 2 }],
    })
    expect(ctrl.validateLeadTime()).toBeNull()
  })

  it("returns a warning when start date is inside the required lead days (after kickoff)", async () => {
    // Same scenario but date is 2026-06-09 — one day short
    const ctrl = await mount({
      startDate: "2026-06-09",
      rows: [{ productId: "1", leadDays: 2 }],
    })
    const result = ctrl.validateLeadTime()
    expect(result).not.toBeNull()
    expect(result.dateMessage).toMatch(/not enough lead days/)
    expect(result.dateMessage).toMatch(/after kickoff/)
    expect(result.actionMessage).toMatch(/will not be automatically invoiced/)
  })

  it("requires one fewer day when order is created before kickoff", async () => {
    restoreDate()
    restoreDate = mockDate("2026-06-07T05:00:00") // before 06:05 kickoff
    // 2 lead days, before kickoff → need exactly 2 days out → earliest = 2026-06-09
    const ctrl = await mount({
      startDate: "2026-06-09",
      rows: [{ productId: "1", leadDays: 2 }],
    })
    expect(ctrl.validateLeadTime()).toBeNull()
  })

  it("warning message does NOT say 'after kickoff' when created before kickoff", async () => {
    restoreDate()
    restoreDate = mockDate("2026-06-07T05:00:00")
    const ctrl = await mount({
      startDate: "2026-06-08", // one day short (need 2)
      rows: [{ productId: "1", leadDays: 2 }],
    })
    const result = ctrl.validateLeadTime()
    expect(result).not.toBeNull()
    expect(result.dateMessage).not.toMatch(/after kickoff/)
  })

  it("uses max lead days across all rows", async () => {
    // 3 lead days (max), after kickoff → need 4 days → earliest = 2026-06-11
    const ctrl = await mount({
      startDate: "2026-06-11",
      rows: [
        { productId: "1", leadDays: 1 },
        { productId: "2", leadDays: 3 },
      ],
    })
    expect(ctrl.validateLeadTime()).toBeNull()
  })
})

// ─── validateEndDate ──────────────────────────────────────────────────────────

describe("validateEndDate", () => {
  it("returns null for temporary orders (end date irrelevant)", async () => {
    const ctrl = await mount({ orderType: "temporary", startDate: "2026-06-10", endDate: "2026-06-08" })
    expect(ctrl.validateEndDate()).toBeNull()
  })

  it("returns null when end date is after start date", async () => {
    const ctrl = await mount({ startDate: "2026-06-10", endDate: "2026-06-20" })
    expect(ctrl.validateEndDate()).toBeNull()
  })

  it("returns null when no end date is set", async () => {
    const ctrl = await mount({ startDate: "2026-06-10", endDate: "" })
    expect(ctrl.validateEndDate()).toBeNull()
  })

  it("returns an error message when end date is before start date", async () => {
    const ctrl = await mount({ startDate: "2026-06-20", endDate: "2026-06-10" })
    expect(ctrl.validateEndDate()).toMatch(/end date cannot be before/)
  })
})

// ─── updateView (end date field visibility) ───────────────────────────────────

describe("updateView", () => {
  it("hides the end date field for temporary orders", async () => {
    await mount({ orderType: "temporary" })
    const field = document.querySelector("[data-order-form-target='endDateField']")
    expect(field.hidden).toBe(true)
  })

  it("shows the end date field for standing orders", async () => {
    await mount({ orderType: "standing" })
    const field = document.querySelector("[data-order-form-target='endDateField']")
    expect(field.hidden).toBe(false)
  })
})

// ─── updateDayInputs ──────────────────────────────────────────────────────────
//
// 2026-06-09 is a Tuesday → getUTCDay() === 2
// Inputs with day !== 2 should be disabled for a temporary order on that date.

describe("updateDayInputs", () => {
  it("disables non-matching day inputs for temporary orders", async () => {
    const ctrl = await mount({
      orderType: "temporary",
      startDate: "2026-06-09", // Tuesday
      dayInputs: [{ day: 0 }, { day: 2 }, { day: 5 }],
    })
    ctrl.updateDayInputs()

    const [sun, tue, fri] = document.querySelectorAll("[data-order-item-day]")
    expect(sun.disabled).toBe(true)   // Sunday, not Tuesday
    expect(tue.disabled).toBe(false)  // Tuesday matches
    expect(fri.disabled).toBe(true)   // Friday, not Tuesday
  })

  it("zeroes out the value of disabled day inputs", async () => {
    const ctrl = await mount({
      orderType: "temporary",
      startDate: "2026-06-09",
      dayInputs: [{ day: 0, value: "3" }],
    })
    ctrl.updateDayInputs()

    const input = document.querySelector("[data-order-item-day='0']")
    expect(input.value).toBe("0")
  })

  it("enables all day inputs for standing orders", async () => {
    const ctrl = await mount({
      orderType: "standing",
      startDate: "2026-06-09",
      dayInputs: [{ day: 0 }, { day: 2 }, { day: 5 }],
    })
    ctrl.updateDayInputs()

    document.querySelectorAll("[data-order-item-day]").forEach(input => {
      expect(input.disabled).toBe(false)
    })
  })
})

// ─── validate (DOM side-effects) ─────────────────────────────────────────────

describe("validate", () => {
  let restoreDate

  beforeEach(() => {
    restoreDate = mockDate("2026-06-07T07:00:00")
  })

  afterEach(() => restoreDate())

  it("adds warning class to submit button when lead time is insufficient", async () => {
    const ctrl = await mount({
      startDate: "2026-06-08", // too soon (need +3 days)
      rows: [{ productId: "1", leadDays: 2 }],
    })
    const btn = document.querySelector("[data-order-form-target='submitBtn']")
    expect(btn.classList.contains("warning")).toBe(true)
  })

  it("removes warning class from submit button when dates are valid", async () => {
    const ctrl = await mount({
      startDate: "2026-06-10", // OK
      rows: [{ productId: "1", leadDays: 2 }],
    })
    const btn = document.querySelector("[data-order-form-target='submitBtn']")
    expect(btn.classList.contains("warning")).toBe(false)
  })

  it("shows the action warning when lead time is insufficient", async () => {
    await mount({
      startDate: "2026-06-08",
      rows: [{ productId: "1", leadDays: 2 }],
    })
    const warn = document.querySelector("[data-order-form-target='actionWarning']")
    expect(warn.hidden).toBe(false)
    expect(warn.textContent).toMatch(/will not be automatically invoiced/)
  })

  it("shows the end date warning when end is before start", async () => {
    await mount({ startDate: "2026-06-20", endDate: "2026-06-10" })
    const warn = document.querySelector("[data-order-form-target='endDateWarning']")
    expect(warn.hidden).toBe(false)
    expect(warn.textContent).toMatch(/end date cannot be before/)
  })
})
