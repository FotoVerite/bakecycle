import { Controller } from "@hotwired/stimulus"

const MINIMUM_ORDER_VALUE = 30
const DAY_NAMES = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

function formatCurrency(amount) {
  return `$${amount.toFixed(2)}`
}

export default class extends Controller {
  static targets = [
    "orderType",
    "startDateField",
    "endDateField",
    "startDate",
    "leadDaysDisplay",
    "startDateWarning",
    "endDateWarning",
    "actionWarning",
    "minimumWarning",
    "dailyTotal",
    "orderTotal",
    "submitBtn"
  ]
  static values = { kickoff: String, orderId: Number, clientId: Number, productPrices: Object }

  connect() {
    this.updateView()
  }

  typeChanged() {
    this.updateView()
  }

  startDateChanged() {
    this.updateDayInputs()
    this.validate()
  }

  clientChanged(event) {
    this.clientIdValue = parseInt(event.target.value, 10) || 0
    this.refreshPricing()
  }

  productChanged() {
    this.updateLeadDays()
    this.updateDayInputs()
    this.syncDedup()
    this.validate()
  }

  // A day-quantity input changed rather than the product itself, but the
  // same downstream updates apply either way.
  rowChanged() {
    this.productChanged()
  }

  updateView() {
    this.endDateFieldTarget.hidden = this.isSingleDayOrder
    this.updateDayInputs()
    this.validate()
  }

  get currentOrderType() {
    const checked = this.orderTypeTargets.find(r => r.checked)
    return checked ? checked.value : ""
  }

  get isSingleDayOrder() {
    return this.currentOrderType === "temporary" || this.currentOrderType === "sample"
  }

  // ─── Row helpers ──────────────────────────────────────────────────────────
  // Shared across lead-day/dedup/pricing logic below, all of which need to
  // walk the same live set of product rows.

  activeRows() {
    return [...this.element.querySelectorAll("[data-order-item-row]")]
      .filter(row => !row.classList.contains("nested-row--destroyed"))
  }

  productSelectFor(row) {
    return row.querySelector("[data-order-item-target='product']")
  }

  dayInputsFor(row) {
    return [...row.querySelectorAll("[data-order-item-day]")]
  }

  quantityOf(input) {
    return parseInt(input.value, 10) || 0
  }

  rowTotalQuantity(row) {
    return this.dayInputsFor(row).reduce((sum, input) => sum + this.quantityOf(input), 0)
  }

  getMaxLeadDays() {
    let max = 0
    this.activeRows().forEach(row => {
      const select = this.productSelectFor(row)
      if (!select || !select.value) return
      const opt = select.options[select.selectedIndex]
      const ld = parseInt(opt?.dataset.leadDays || "0", 10)
      if (!isNaN(ld) && ld > max) max = ld
    })
    return max
  }

  updateLeadDays() {
    const max = this.getMaxLeadDays()
    if (this.hasLeadDaysDisplayTarget) this.leadDaysDisplayTarget.textContent = max
  }

  syncDedup() {
    const selects = this.activeRows().map(row => this.productSelectFor(row)).filter(Boolean)
    const selected = new Set(selects.map(select => select.value).filter(value => value !== ""))

    selects.forEach(select => {
      select.querySelectorAll("option").forEach(opt => {
        opt.disabled = opt.value !== "" && opt.value !== select.value && selected.has(opt.value)
      })
      if (select.tomselect) select.tomselect.sync()
    })
  }

  // Highlight a day cell's whole value on focus so typing replaces it, rather
  // than dropping a caret. Deferred a frame so the click's own mouseup (which
  // otherwise collapses the selection to a caret) doesn't undo it.
  selectContents(event) {
    const input = event.target
    requestAnimationFrame(() => input.select())
  }

  updateDayInputs() {
    const isSingleDayOrder = this.isSingleDayOrder
    const startDate = this.startDateTarget.value

    this.element.querySelectorAll("[data-order-item-day]").forEach(input => {
      if (isSingleDayOrder && startDate) {
        const dayNum = parseInt(input.dataset.orderItemDay, 10)
        const d = new Date(startDate + "T00:00:00")
        const shouldDisable = d.getUTCDay() !== dayNum
        input.disabled = shouldDisable
      } else {
        input.disabled = false
      }
    })
  }

  validate() {
    const leadWarning = this.validateLeadTime()
    const endMsg = this.validateEndDate()
    const error = leadWarning || endMsg
    this.clearFieldWarnings()

    if (error) {
      if (leadWarning) {
        if (this.hasStartDateFieldTarget && this.hasStartDateWarningTarget) {
          this.showFieldWarning(this.startDateFieldTarget, this.startDateWarningTarget, leadWarning.dateMessage)
        }
        this.showActionWarning(leadWarning.actionMessage)
      }
      if (endMsg && this.hasEndDateFieldTarget && this.hasEndDateWarningTarget) {
        this.showFieldWarning(this.endDateFieldTarget, this.endDateWarningTarget, endMsg)
      }
      if (this.hasSubmitBtnTarget) this.submitBtnTarget.classList.add("warning")
    } else {
      if (this.hasSubmitBtnTarget) this.submitBtnTarget.classList.remove("warning")
    }

    this.refreshPricing()
  }

  // Recomputes every row's displayed price/quantity (previously blank until
  // the order was saved and reloaded), the per-day total strip (with its
  // per-product tooltip breakdown), the whole-order total, and the $30/day
  // minimum warning -- all driven by the same productPricesValue cache
  // embedded on the form (see OrdersController#product_prices_json) and the
  // same per-day breakdown, computed once here and passed down so five
  // different displays don't each re-walk every row. Called from every place
  // validate() already runs so it stays in sync with lead-time/end-date
  // validation.
  refreshPricing() {
    const breakdown = this.computeDailyBreakdown()
    this.updateRowDisplays()
    this.updateDailyTotalsDisplay(breakdown)
    this.updateGrandTotal(breakdown)
    this.checkMinimumOrderValue(breakdown)
  }

  // Small per-weekday total strip under the product rows -- lets staff see at
  // a glance which day(s) the $30 minimum warning is actually complaining
  // about, without having to add up the rows themselves. Each day's figure
  // also carries a hover/focus tooltip listing that day's per-product
  // amounts (a full always-visible breakdown wouldn't fit the 52px day
  // columns) -- content is set here rather than in CSS since it's dynamic
  // and needs one row per product, not a single string.
  updateDailyTotalsDisplay(breakdown = this.computeDailyBreakdown()) {
    if (!this.hasDailyTotalTarget) return

    this.dailyTotalTargets.forEach(el => {
      const day = el.dataset.dayTotal
      const items = breakdown[day] || []
      const valueEl = el.querySelector(".order-item-daily-total-value")
      if (valueEl) valueEl.textContent = formatCurrency(this.sumAmounts(items))

      const tooltip = el.querySelector("[data-order-form-target='dailyTotalTooltip']")
      if (!tooltip) return

      tooltip.innerHTML = ""
      tooltip.hidden = items.length === 0
      tooltip.append(...items.map(item => this.buildTooltipRow(item)))
    })
  }

  buildTooltipRow(item) {
    const row = document.createElement("div")
    row.className = "order-item-daily-total-tooltip-row"

    const name = document.createElement("span")
    name.textContent = item.name
    const amount = document.createElement("span")
    amount.textContent = formatCurrency(item.amount)

    row.append(name, amount)
    return row
  }

  // The whole order's total across every day -- shown in the daily-totals
  // strip's Total column, the same column the per-row totals above it sit in.
  updateGrandTotal(breakdown = this.computeDailyBreakdown()) {
    if (!this.hasOrderTotalTarget) return

    this.orderTotalTarget.textContent = formatCurrency(this.sumAmounts(Object.values(breakdown).flat()))
  }

  // Mirrors Product#lookup_price_variant: the tightest quantity tier at or
  // below the ordered amount, preferring a client-specific override over the
  // client-wide (client_id: null) default, falling back to the product's
  // base price when no tier matches.
  //
  // $0.00 entries are treated as "no real price configured" rather than a
  // deliberately free item -- some products have a $0 variant/base price
  // that's really just incomplete pricing data (e.g. a client-wide $0 tier
  // sitting alongside real client-specific prices for everyone else). Letting
  // that win would silently zero out the row's estimate -- and the $30/day
  // minimum check along with it -- for an order that's actually priced. So
  // $0 candidates are skipped in favor of the product's base price, and
  // failing that, the highest non-zero price configured anywhere for the
  // product (any client/tier), before finally accepting $0 as a last resort.
  priceFor(productId, quantity) {
    const product = this.productPricesValue[productId]
    if (!product) return null

    const clientId = this.clientIdValue || null
    const scoped = (product.variants || [])
      .filter(variant => (variant.client_id === null || variant.client_id === clientId) && parseFloat(variant.price) > 0)
      .sort((a, b) => {
        if (b.quantity !== a.quantity) return b.quantity - a.quantity
        // Same tier -- prefer the client-specific override over the client-wide default.
        return (a.client_id === null ? 1 : 0) - (b.client_id === null ? 1 : 0)
      })

    const matching = scoped.find(variant => variant.quantity <= quantity)
    if (matching) return parseFloat(matching.price)

    const base = parseFloat(product.base)
    if (base > 0) return base

    const anyNonZero = (product.variants || []).map(variant => parseFloat(variant.price)).filter(price => price > 0)
    return anyNonZero.length ? Math.max(...anyNonZero) : 0
  }

  updateRowDisplays() {
    this.activeRows().forEach(row => {
      const priceQtyEl = row.querySelector("[data-order-item-target='priceQuantity']")
      const totalEl = row.querySelector("[data-order-item-target='totalPrice']")
      if (!priceQtyEl && !totalEl) return

      const select = this.productSelectFor(row)
      const totalQty = this.rowTotalQuantity(row)
      const unitPrice = select && select.value && totalQty > 0 ? this.priceFor(select.value, totalQty) : null

      if (priceQtyEl) priceQtyEl.textContent = unitPrice != null ? `${formatCurrency(unitPrice)} @${totalQty}pc` : ""
      if (totalEl) totalEl.textContent = unitPrice != null ? formatCurrency(unitPrice * totalQty) : ""
    })
  }

  // Per-weekday breakdown across every row -- each item's unit price is
  // looked up once from its *weekly* total quantity (matching
  // OrderItem#product_price/#total_quantity_price), then applied to that
  // item's quantity on each individual day. Returns { [day]: [{name, amount}] }.
  computeDailyBreakdown() {
    const breakdown = { 0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [] }

    this.activeRows().forEach(row => {
      const select = this.productSelectFor(row)
      if (!select || !select.value) return

      const totalQty = this.rowTotalQuantity(row)
      if (totalQty <= 0) return

      const unitPrice = this.priceFor(select.value, totalQty)
      if (unitPrice == null) return

      const name = select.options[select.selectedIndex]?.textContent.trim() || "Item"

      this.dayInputsFor(row).forEach(input => {
        if (input.disabled) return
        const qty = this.quantityOf(input)
        if (qty <= 0) return
        breakdown[input.dataset.orderItemDay].push({ name, amount: qty * unitPrice })
      })
    })

    return breakdown
  }

  sumAmounts(items) {
    return items.reduce((sum, item) => sum + item.amount, 0)
  }

  // Only for brand-new orders -- once an order exists, staff regularly
  // approve below-minimum days on purpose (see original request), so
  // re-flagging it forever on every edit would just be noise.
  checkMinimumOrderValue(breakdown = this.computeDailyBreakdown()) {
    if (!this.hasMinimumWarningTarget) return
    if (this.orderIdValue) {
      this.minimumWarningTarget.hidden = true
      return
    }

    const totals = {}
    Object.keys(breakdown).forEach(day => { totals[day] = this.sumAmounts(breakdown[day]) })
    const isTemporary = this.currentOrderType === "temporary"

    let relevantDays = [0, 1, 2, 3, 4, 5, 6]
    if (isTemporary) {
      const startDate = this.hasStartDateTarget ? this.startDateTarget.value : ""
      if (!startDate) {
        this.minimumWarningTarget.hidden = true
        return
      }
      relevantDays = [new Date(`${startDate}T00:00:00`).getUTCDay()]
    }

    const lowDays = relevantDays
      .filter(dayNum => totals[dayNum] > 0 && totals[dayNum] < MINIMUM_ORDER_VALUE)
      .map(dayNum => `${DAY_NAMES[dayNum]} (${formatCurrency(totals[dayNum])})`)

    if (lowDays.length === 0) {
      this.minimumWarningTarget.hidden = true
      return
    }

    this.minimumWarningTarget.textContent =
      `Warning: this order totals under the $30 minimum on ${lowDays.join(", ")}. ` +
      "You can still create it as-is if this is intentional."
    this.minimumWarningTarget.hidden = false
  }

  clearFieldWarnings() {
    if (this.hasStartDateFieldTarget) this.startDateFieldTarget.classList.remove("form-field--error")
    if (this.hasEndDateFieldTarget) this.endDateFieldTarget.classList.remove("form-field--error")
    if (this.hasStartDateWarningTarget) this.startDateWarningTarget.hidden = true
    if (this.hasEndDateWarningTarget) this.endDateWarningTarget.hidden = true
    if (this.hasActionWarningTarget) this.actionWarningTarget.hidden = true
  }

  showFieldWarning(field, warning, message) {
    if (!field || !warning) return
    field.classList.add("form-field--error")
    warning.textContent = message
    warning.hidden = false
  }

  showActionWarning(message) {
    if (!this.hasActionWarningTarget) return
    this.actionWarningTarget.textContent = message
    this.actionWarningTarget.hidden = false
  }

  validateLeadTime() {
    const orderId = this.orderIdValue
    const orderType = this.currentOrderType
    if (orderId && orderType === "standing") return null

    const startDate = this.startDateTarget.value
    if (!startDate || !this.kickoffValue) return null

    const [h, m] = this.kickoffValue.split(":").map(Number)
    const now = new Date()
    const kickoffToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), h, m + 5)
    const isBeforeKickoff = now < kickoffToday

    const totalLeadDays = this.getMaxLeadDays()
    const neededLeadDays = totalLeadDays + (isBeforeKickoff ? 0 : 1)

    const mustStartAfter = new Date()
    mustStartAfter.setDate(mustStartAfter.getDate() + neededLeadDays)
    mustStartAfter.setHours(0, 0, 0, 0)

    const start = new Date(startDate + "T00:00:00")
    if (start < mustStartAfter) {
      const formatted = mustStartAfter.toLocaleDateString("en-US")
      const suffix = isBeforeKickoff ? "" : ", it's after kickoff"
      return {
        dateMessage: `There are not enough lead days${suffix}. The earliest date would be ${formatted}`,
        actionMessage: "Warning, this order is being created without minimum lead days and will not be automatically invoiced."
      }
    }
    return null
  }

  validateEndDate() {
    if (this.isSingleDayOrder) return null
    const startDate = this.startDateTarget.value
    const endInput = this.endDateFieldTarget.querySelector("input[type='date']")
    if (!endInput || !startDate || !endInput.value) return null
    const start = new Date(startDate + "T00:00:00")
    const end = new Date(endInput.value + "T00:00:00")
    if (start > end) return "The end date cannot be before the start date"
    return null
  }
}
