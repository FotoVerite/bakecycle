import { Controller } from "@hotwired/stimulus"

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
    "submitBtn"
  ]
  static values = { kickoff: String, orderId: Number }

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

  productChanged() {
    this.updateLeadDays()
    this.updateDayInputs()
    this.syncDedup()
    this.validate()
  }

  rowChanged() {
    this.updateLeadDays()
    this.updateDayInputs()
    this.syncDedup()
    this.validate()
  }

  updateView() {
    const isTemporary = this.currentOrderType === "temporary"
    this.endDateFieldTarget.hidden = isTemporary
    this.updateDayInputs()
    this.validate()
  }

  get currentOrderType() {
    const checked = this.orderTypeTargets.find(r => r.checked)
    return checked ? checked.value : ""
  }

  getMaxLeadDays() {
    const rows = [...this.element.querySelectorAll("[data-order-item-row]")]
      .filter(r => !r.classList.contains("nested-row--destroyed"))
    let max = 0
    rows.forEach(row => {
      const select = row.querySelector("[data-order-item-target='product']")
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
    const rows = [...this.element.querySelectorAll("[data-order-item-row]")]
      .filter(r => !r.classList.contains("nested-row--destroyed"))
    const selects = rows.map(r => r.querySelector("[data-order-item-target='product']")).filter(Boolean)
    const selected = new Set(selects.map(s => s.value).filter(v => v !== ""))

    selects.forEach(select => {
      select.querySelectorAll("option").forEach(opt => {
        opt.disabled = opt.value !== "" && opt.value !== select.value && selected.has(opt.value)
      })
      if (select.tomselect) select.tomselect.sync()
    })
  }

  updateDayInputs() {
    const isTemporary = this.currentOrderType === "temporary"
    const startDate = this.startDateTarget.value

    this.element.querySelectorAll("[data-order-item-day]").forEach(input => {
      if (isTemporary && startDate) {
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
    if (this.currentOrderType === "temporary") return null
    const startDate = this.startDateTarget.value
    const endInput = this.endDateFieldTarget.querySelector("input[type='date']")
    if (!endInput || !startDate || !endInput.value) return null
    const start = new Date(startDate + "T00:00:00")
    const end = new Date(endInput.value + "T00:00:00")
    if (start > end) return "The end date cannot be before the start date"
    return null
  }
}
