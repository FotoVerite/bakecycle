import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { selfUrl: String, loadingMessage: String }
  static targets = ["message", "status"]

  connect() {
    this.messageTarget.textContent = this.loadingMessageValue
    this.poll()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  poll() {
    fetch(this.selfUrlValue, { headers: { Accept: "application/json" } })
      .then(r => r.json())
      .then(data => {
        const export_ = data.fileExport || data
        if (export_["ready?"]) {
          window.location.replace(export_.links.file)
        } else {
          this.timeout = setTimeout(() => this.poll(), 1000)
        }
      })
      .catch(() => {
        this.statusTarget.textContent = "There was an error checking on the report, trying again in 5 seconds."
        this.timeout = setTimeout(() => this.poll(), 5000)
      })
  }
}
