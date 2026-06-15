import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"
import zoomPlugin from "chartjs-plugin-zoom"
import "chartjs-adapter-date-fns"

Chart.register(zoomPlugin)

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    labels: Array,
    data: Array,
    title: String,
    format: String,
  }

  connect() {
    const isCurrency = this.formatValue === "currency"
    const labels = this.labelsValue
    const lastDate = labels.length ? new Date(labels[labels.length - 1]) : new Date()
    const defaultMin = new Date(lastDate)
    defaultMin.setMonth(defaultMin.getMonth() - 12)

    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            data: this.dataValue,
            borderColor: "#17BECF",
            backgroundColor: "rgba(23, 190, 207, 0.12)",
            borderWidth: 2,
            pointRadius: 0,
            pointHoverRadius: 4,
            tension: 0.15,
            fill: true,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: "index",
          intersect: false,
        },
        plugins: {
          legend: { display: false },
          title: { display: true, text: this.titleValue },
          tooltip: {
            callbacks: {
              label: context => {
                const value = context.parsed.y
                return isCurrency ? `$${value.toLocaleString()}` : value.toLocaleString()
              },
            },
          },
          zoom: {
            limits: {
              x: { min: "original", max: "original" },
            },
            pan: {
              enabled: true,
              mode: "x",
            },
            zoom: {
              wheel: { enabled: true },
              pinch: { enabled: true },
              drag: { enabled: false },
              mode: "x",
            },
          },
        },
        scales: {
          x: {
            type: "time",
            time: { unit: "month" },
            min: defaultMin.toISOString(),
            max: lastDate.toISOString(),
            ticks: {
              maxRotation: 0,
              autoSkipPadding: 16,
            },
          },
          y: {
            beginAtZero: true,
            ticks: {
              callback: value => (isCurrency ? `$${value.toLocaleString()}` : value.toLocaleString()),
            },
          },
        },
      },
    })
  }

  resetZoom() {
    if (this.chart) {
      this.chart.resetZoom()
    }
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
