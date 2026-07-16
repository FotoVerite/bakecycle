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
// rows: [{ productId, leadDays, selected, destroyed, dayValues: { [dayNum]: qty } }]
// dayValues renders one data-order-item-day input per entry, inside that row
// (so rowTotalQuantity/computeDailyTotals can find them via row.querySelectorAll).
function buildFixture({
  orderType     = "standing",
  startDate     = "",
  endDate       = "",
  orderId       = 0,
  clientId      = 0,
  kickoff       = "06:00",
  rows          = [],
  dayInputs     = [],
  productPrices = null,
  withMinimumWarningTarget = false,
  withPriceTargets = false,
  withDailyTotalTargets = false,
  withOrderTotalTarget = false,
} = {}) {
  const rowsHtml = rows.map(({
    productId = "1", leadDays = 0, selected = true, destroyed = false, dayValues = {},
  }) => {
    const rowDayHtml = Object.entries(dayValues).map(([day, value]) => `
      <input data-order-item-day="${day}" type="number" value="${value}">
    `).join("")
    const priceTargetsHtml = withPriceTargets ? `
      <span data-order-item-target="priceQuantity"></span>
      <span data-order-item-target="totalPrice"></span>
    ` : ""

    return `
      <div data-order-item-row${destroyed ? ' class="nested-row--destroyed"' : ""}>
        <select data-order-item-target="product">
          <option value="">Select...</option>
          <option value="${productId}" data-lead-days="${leadDays}"${selected ? " selected" : ""}>
            Product ${productId}
          </option>
        </select>
        ${priceTargetsHtml}
        ${rowDayHtml}
      </div>
    `
  }).join("")

  const dayHtml = dayInputs.map(({ day, value = "1" }) => `
    <input data-order-item-day="${day}" type="number" value="${value}">
  `).join("")

  const productPricesAttr = productPrices
    ? `data-order-form-product-prices-value='${JSON.stringify(productPrices)}'`
    : ""
  const minimumWarningHtml = withMinimumWarningTarget
    ? '<span data-order-form-target="minimumWarning" hidden></span>'
    : ""
  const dailyTotalsHtml = withDailyTotalTargets
    ? [0, 1, 2, 3, 4, 5, 6].map(day => `
        <div data-order-form-target="dailyTotal" data-day-total="${day}">
          <span class="order-item-daily-total-value"></span>
          <div data-order-form-target="dailyTotalTooltip" data-day-total-tooltip="${day}" hidden></div>
        </div>
      `).join("")
    : ""
  const orderTotalHtml = withOrderTotalTarget
    ? '<span data-order-form-target="orderTotal"></span>'
    : ""

  return `
    <div
      data-controller="order-form"
      data-order-form-kickoff-value="${kickoff}"
      data-order-form-order-id-value="${orderId}"
      data-order-form-client-id-value="${clientId}"
      ${productPricesAttr}
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
      ${minimumWarningHtml}
      ${dailyTotalsHtml}
      ${orderTotalHtml}
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

  it("preserves the displayed value of disabled day inputs", async () => {
    const ctrl = await mount({
      orderType: "temporary",
      startDate: "2026-06-09",
      dayInputs: [{ day: 0, value: "3" }],
    })
    ctrl.updateDayInputs()

    const input = document.querySelector("[data-order-item-day='0']")
    expect(input.disabled).toBe(true)
    expect(input.value).toBe("3")
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

  it("locks newly added row day inputs after a temporary order date is selected", async () => {
    const ctrl = await mount({
      orderType: "temporary",
      startDate: "2026-06-09",
      dayInputs: [{ day: 0 }, { day: 2 }, { day: 5 }],
    })

    document.querySelectorAll("[data-order-item-day]").forEach(input => {
      input.disabled = false
    })

    ctrl.rowChanged()

    const [sun, tue, fri] = document.querySelectorAll("[data-order-item-day]")
    expect(sun.disabled).toBe(true)
    expect(tue.disabled).toBe(false)
    expect(fri.disabled).toBe(true)
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

// ─── priceFor ─────────────────────────────────────────────────────────────────

describe("priceFor", () => {
  const productPrices = {
    1: {
      base: "2.00",
      variants: [
        { client_id: null, quantity: 10, price: "1.80" },
        { client_id: null, quantity: 50, price: "1.50" },
        { client_id: 7, quantity: 10, price: "1.60" },
      ],
    },
  }

  it("falls back to base price when no variant tier matches", async () => {
    const ctrl = await mount({ productPrices })
    expect(ctrl.priceFor("1", 5)).toBe(2.00)
  })

  it("uses the tightest client-wide tier at or below the quantity", async () => {
    const ctrl = await mount({ productPrices })
    expect(ctrl.priceFor("1", 10)).toBe(1.80)
    expect(ctrl.priceFor("1", 49)).toBe(1.80)
    expect(ctrl.priceFor("1", 50)).toBe(1.50)
  })

  it("prefers a client-specific override over the client-wide tier", async () => {
    const ctrl = await mount({ productPrices, clientId: 7 })
    expect(ctrl.priceFor("1", 10)).toBe(1.60)
  })

  it("ignores another client's override", async () => {
    const ctrl = await mount({ productPrices, clientId: 99 })
    expect(ctrl.priceFor("1", 10)).toBe(1.80)
  })

  it("returns null for an unknown product", async () => {
    const ctrl = await mount({ productPrices })
    expect(ctrl.priceFor("999", 10)).toBeNull()
  })
})

// ─── priceFor: $0 entries treated as unpriced ────────────────────────────────

describe("priceFor zero-price fallback", () => {
  it("skips a $0 client-wide variant in favor of a non-zero base price", async () => {
    const productPrices = {
      1: {
        base: "2.50",
        variants: [{ client_id: null, quantity: 1, price: "0.0" }],
      },
    }
    const ctrl = await mount({ productPrices })
    expect(ctrl.priceFor("1", 22)).toBe(2.5)
  })

  it("skips a $0 tier even when a same-tier client-specific $0 duplicate exists", async () => {
    const productPrices = {
      1: {
        base: "0.0",
        variants: [
          { client_id: null, quantity: 1, price: "0.0" },
          { client_id: null, quantity: 1, price: "0.397" },
        ],
      },
    }
    const ctrl = await mount({ productPrices })
    expect(ctrl.priceFor("1", 1)).toBe(0.397)
  })

  it("falls back to the highest non-zero variant anywhere when base is also $0", async () => {
    const productPrices = {
      1: {
        base: "0.0",
        variants: [
          { client_id: 32982, quantity: 1, price: "0.397" },
          { client_id: 33013, quantity: 1, price: "0.0" },
        ],
      },
    }
    const ctrl = await mount({ productPrices, clientId: 33013 })
    expect(ctrl.priceFor("1", 1)).toBe(0.397)
  })

  it("returns 0 only when nothing anywhere is priced above $0", async () => {
    const productPrices = {
      1: { base: "0.0", variants: [{ client_id: null, quantity: 1, price: "0.0" }] },
    }
    const ctrl = await mount({ productPrices })
    expect(ctrl.priceFor("1", 1)).toBe(0)
  })
})

// ─── updateRowDisplays ──────────────────────────────────────────────────────────

describe("updateRowDisplays", () => {
  const productPrices = { 1: { base: "2.00", variants: [] } }

  it("displays the computed price and quantity for a row with quantity entered", async () => {
    const ctrl = await mount({
      productPrices,
      withPriceTargets: true,
      rows: [{ productId: "1", dayValues: { 1: "3", 2: "4" } }],
    })
    ctrl.updateRowDisplays()

    const row = document.querySelector("[data-order-item-row]")
    expect(row.querySelector("[data-order-item-target='priceQuantity']").textContent).toBe("$2.00 @7pc")
    expect(row.querySelector("[data-order-item-target='totalPrice']").textContent).toBe("$14.00")
  })

  it("leaves the row blank when no product is selected", async () => {
    const ctrl = await mount({
      productPrices,
      withPriceTargets: true,
      rows: [{ productId: "", selected: false, dayValues: { 1: "3" } }],
    })
    ctrl.updateRowDisplays()

    const row = document.querySelector("[data-order-item-row]")
    expect(row.querySelector("[data-order-item-target='priceQuantity']").textContent).toBe("")
    expect(row.querySelector("[data-order-item-target='totalPrice']").textContent).toBe("")
  })

  it("leaves the row blank when quantity is zero", async () => {
    const ctrl = await mount({
      productPrices,
      withPriceTargets: true,
      rows: [{ productId: "1", dayValues: { 1: "0" } }],
    })
    ctrl.updateRowDisplays()

    const row = document.querySelector("[data-order-item-row]")
    expect(row.querySelector("[data-order-item-target='priceQuantity']").textContent).toBe("")
  })
})

// ─── computeDailyBreakdown ────────────────────────────────────────────────────

describe("computeDailyBreakdown", () => {
  it("lists each day's per-product amounts using each row's weekly unit price", async () => {
    const productPrices = {
      1: { base: "2.00", variants: [] },
      2: { base: "5.00", variants: [] },
    }
    const ctrl = await mount({
      productPrices,
      rows: [
        { productId: "1", dayValues: { 1: "10", 2: "5" } },
        { productId: "2", dayValues: { 1: "2" } },
      ],
    })

    const breakdown = ctrl.computeDailyBreakdown()
    expect(ctrl.sumAmounts(breakdown[1])).toBe(10 * 2.00 + 2 * 5.00)
    expect(breakdown[1].map(item => item.name)).toEqual(["Product 1", "Product 2"])
    expect(ctrl.sumAmounts(breakdown[2])).toBe(5 * 2.00)
    expect(breakdown[3]).toEqual([])
  })

  it("ignores disabled day inputs", async () => {
    const productPrices = { 1: { base: "2.00", variants: [] } }
    const ctrl = await mount({
      productPrices,
      rows: [{ productId: "1", dayValues: { 1: "10" } }],
    })
    document.querySelector("[data-order-item-day='1']").disabled = true

    expect(ctrl.computeDailyBreakdown()[1]).toEqual([])
  })
})

// ─── checkMinimumOrderValue ───────────────────────────────────────────────────

describe("checkMinimumOrderValue", () => {
  const lowProductPrices = { 1: { base: "2.00", variants: [] } } // $2/unit

  it("does nothing when there is no minimumWarning target", async () => {
    const ctrl = await mount({ productPrices: lowProductPrices, rows: [{ productId: "1", dayValues: { 1: "5" } }] })
    expect(() => ctrl.checkMinimumOrderValue()).not.toThrow()
  })

  it("stays hidden for an existing (persisted) order", async () => {
    const ctrl = await mount({
      orderId: 42,
      withMinimumWarningTarget: true,
      productPrices: lowProductPrices,
      rows: [{ productId: "1", dayValues: { 1: "5" } }], // $10, under $30
    })
    ctrl.checkMinimumOrderValue()
    const warn = document.querySelector("[data-order-form-target='minimumWarning']")
    expect(warn.hidden).toBe(true)
  })

  it("warns on a new standing order when a day's total is under $30", async () => {
    const ctrl = await mount({
      withMinimumWarningTarget: true,
      productPrices: lowProductPrices,
      rows: [{ productId: "1", dayValues: { 1: "5" } }], // Monday: $10
    })
    ctrl.checkMinimumOrderValue()
    const warn = document.querySelector("[data-order-form-target='minimumWarning']")
    expect(warn.hidden).toBe(false)
    expect(warn.textContent).toMatch(/Monday \(\$10\.00\)/)
  })

  it("does not warn on a day with no order at all", async () => {
    const ctrl = await mount({
      withMinimumWarningTarget: true,
      productPrices: lowProductPrices,
      rows: [{ productId: "1", dayValues: { 1: "20" } }], // Monday: $40, fine; other days: $0, not flagged
    })
    ctrl.checkMinimumOrderValue()
    const warn = document.querySelector("[data-order-form-target='minimumWarning']")
    expect(warn.hidden).toBe(true)
  })

  it("only checks the temporary order's single active day", async () => {
    // 2026-06-09 is a Tuesday (day 2)
    const ctrl = await mount({
      orderType: "temporary",
      startDate: "2026-06-09",
      withMinimumWarningTarget: true,
      productPrices: lowProductPrices,
      rows: [{ productId: "1", dayValues: { 2: "5" } }], // Tuesday: $10, under $30
    })
    ctrl.checkMinimumOrderValue()
    const warn = document.querySelector("[data-order-form-target='minimumWarning']")
    expect(warn.hidden).toBe(false)
    expect(warn.textContent).toMatch(/Tuesday/)
  })

  it("does not warn when the day's total meets the minimum", async () => {
    const ctrl = await mount({
      withMinimumWarningTarget: true,
      productPrices: lowProductPrices,
      rows: [{ productId: "1", dayValues: { 1: "15" } }], // Monday: $30
    })
    ctrl.checkMinimumOrderValue()
    const warn = document.querySelector("[data-order-form-target='minimumWarning']")
    expect(warn.hidden).toBe(true)
  })
})

// ─── clientChanged ────────────────────────────────────────────────────────────

describe("clientChanged", () => {
  it("updates clientIdValue and refreshes pricing displays", async () => {
    const productPrices = {
      1: {
        base: "2.00",
        variants: [{ client_id: 7, quantity: 1, price: "1.00" }],
      },
    }
    const ctrl = await mount({
      productPrices,
      withPriceTargets: true,
      rows: [{ productId: "1", dayValues: { 1: "3" } }],
    })

    ctrl.clientChanged({ target: { value: "7" } })

    expect(ctrl.clientIdValue).toBe(7)
    const row = document.querySelector("[data-order-item-row]")
    expect(row.querySelector("[data-order-item-target='priceQuantity']").textContent).toBe("$1.00 @3pc")
  })
})

// ─── updateDailyTotalsDisplay ─────────────────────────────────────────────────

describe("updateDailyTotalsDisplay", () => {
  it("does nothing when there are no dailyTotal targets", async () => {
    const ctrl = await mount({
      productPrices: { 1: { base: "2.00", variants: [] } },
      rows: [{ productId: "1", dayValues: { 1: "5" } }],
    })
    expect(() => ctrl.updateDailyTotalsDisplay()).not.toThrow()
  })

  it("displays each weekday's dollar total and $0.00 for days with nothing ordered", async () => {
    const ctrl = await mount({
      withDailyTotalTargets: true,
      productPrices: { 1: { base: "2.00", variants: [] } },
      rows: [{ productId: "1", dayValues: { 1: "10", 2: "5" } }],
    })
    ctrl.updateDailyTotalsDisplay()

    const valueFor = day =>
      document.querySelector(`[data-order-form-target='dailyTotal'][data-day-total="${day}"] .order-item-daily-total-value`).textContent
    expect(valueFor(1)).toBe("$20.00")
    expect(valueFor(2)).toBe("$10.00")
    expect(valueFor(3)).toBe("$0.00")
  })

  it("populates the tooltip with a per-product breakdown and hides it when the day is empty", async () => {
    const ctrl = await mount({
      withDailyTotalTargets: true,
      productPrices: {
        1: { base: "2.00", variants: [] },
        2: { base: "5.00", variants: [] },
      },
      rows: [
        { productId: "1", dayValues: { 1: "10" } },
        { productId: "2", dayValues: { 1: "2" } },
      ],
    })
    ctrl.updateDailyTotalsDisplay()

    const tooltipFor = day => document.querySelector(`[data-order-form-target='dailyTotalTooltip'][data-day-total-tooltip="${day}"]`)
    const mondayTooltip = tooltipFor(1)
    expect(mondayTooltip.hidden).toBe(false)
    const rows = [...mondayTooltip.querySelectorAll(".order-item-daily-total-tooltip-row")].map(r => r.textContent)
    expect(rows).toEqual(["Product 1$20.00", "Product 2$10.00"])

    expect(tooltipFor(3).hidden).toBe(true)
  })
})

// ─── updateGrandTotal ─────────────────────────────────────────────────────────

describe("updateGrandTotal", () => {
  it("does nothing when there is no orderTotal target", async () => {
    const ctrl = await mount({
      productPrices: { 1: { base: "2.00", variants: [] } },
      rows: [{ productId: "1", dayValues: { 1: "5" } }],
    })
    expect(() => ctrl.updateGrandTotal()).not.toThrow()
  })

  it("sums every day's total into the whole-order total", async () => {
    const ctrl = await mount({
      withOrderTotalTarget: true,
      productPrices: { 1: { base: "2.00", variants: [] } },
      rows: [{ productId: "1", dayValues: { 1: "10", 2: "5", 5: "3" } }],
    })
    ctrl.updateGrandTotal()

    const total = document.querySelector("[data-order-form-target='orderTotal']").textContent
    expect(total).toBe("$36.00") // (10 + 5 + 3) * $2.00
  })
})
