import { Controller } from "@hotwired/stimulus"

const TIMEOUT_MS = 5 * 60 * 1000   // 5 minutes
const MAX_ERRORS = 3                 // stop after 3 consecutive 5xx / network errors

export default class extends Controller {
  static values = { selfUrl: String, loadingMessage: String }
  static targets = ["message", "status"]

  connect() {
    this.disconnected = false
    this.startTime = Date.now()
    this.errorCount = 0
    this.messageTarget.textContent = this.loadingMessageValue
    this.poll()
  }

  disconnect() {
    this.disconnected = true
    clearTimeout(this.timeout)
    this.abortController?.abort()
  }

  stop(message) {
    this.statusTarget.textContent = message
  }

  poll() {
    if (this.disconnected) return
    if (Date.now() - this.startTime >= TIMEOUT_MS) {
      this.stop("Report generation timed out after 5 minutes. Please try again.")
      return
    }

    this.abortController = new AbortController()
    fetch(this.selfUrlValue, {
      headers: { Accept: "application/json" },
      signal: this.abortController.signal
    })
      .then(r => {
        if (r.status === 404) {
          this.stop("This report is no longer available.")
          return null
        }
        if (!r.ok) {
          this.errorCount++
          if (this.errorCount >= MAX_ERRORS) {
            this.stop(`Report generation failed (server error ${r.status}). Please try again.`)
            return null
          }
          this.statusTarget.textContent = `Server error (${r.status}), retrying…`
          this.timeout = setTimeout(() => this.poll(), 5000)
          return null
        }
        this.errorCount = 0
        return r.json()
      })
      .then(data => {
        if (!data || this.disconnected) return
        const export_ = data.fileExport || data
        if (export_["ready?"]) {
          window.location.replace(export_.links.file)
        } else {
          this.timeout = setTimeout(() => this.poll(), 1000)
        }
      })
      .catch(error => {
        if (error.name === "AbortError" || this.disconnected) return
        this.errorCount++
        if (this.errorCount >= MAX_ERRORS) {
          this.stop("Unable to reach the server. Please try again.")
          return
        }
        this.statusTarget.textContent = `Network error, retrying in 5 seconds… (${this.errorCount}/${MAX_ERRORS})`
        this.timeout = setTimeout(() => this.poll(), 5000)
      })
  }
}
