import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "end"]

  setDays(event) {
    const days = parseInt(event.currentTarget.dataset.days, 10)
    const start = this.startDate
    if (!start || Number.isNaN(days)) return

    start.setDate(start.getDate() + days)
    this.endTarget.value = this.formatDate(start)
  }

  get startDate() {
    if (!this.startTarget.value) return null

    const [year, month, day] = this.startTarget.value.split("-").map(Number)
    if (!year || !month || !day) return null

    return new Date(year, month - 1, day)
  }

  formatDate(date) {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, "0")
    const day = `${date.getDate()}`.padStart(2, "0")
    return `${year}-${month}-${day}`
  }
}
