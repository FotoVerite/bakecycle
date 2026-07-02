import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

// Two-series line chart for the Plan vs Created comparison page.
export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    labels: Array,
    baselineData: Array,
    compareData: Array,
    baselineLabel: String,
    compareLabel: String,
  }

  connect() {
    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: this.baselineLabelValue,
            data: this.baselineDataValue,
            borderColor: "#5a5a5a",
            backgroundColor: "rgba(90, 90, 90, 0.08)",
            borderWidth: 2,
            pointRadius: 2,
            pointHoverRadius: 4,
            tension: 0.15,
            fill: false,
          },
          {
            label: this.compareLabelValue,
            data: this.compareDataValue,
            borderColor: "#55aad7",
            backgroundColor: "rgba(85, 170, 215, 0.12)",
            borderWidth: 2,
            pointRadius: 2,
            pointHoverRadius: 4,
            tension: 0.15,
            fill: true,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        plugins: {
          legend: { display: true, position: "bottom" },
        },
        scales: {
          y: { beginAtZero: true, ticks: { precision: 0 } },
        },
      },
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
