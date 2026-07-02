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

  // Same semantic red/green the differences table uses for its Δ column
  // ($bc-alizarin-crimson / $bc-fulfillment-fg), so the chart and table read
  // as one vocabulary rather than two.
  static SHORT_FILL = "rgba(235, 50, 50, 0.22)"
  static OVER_FILL = "rgba(79, 107, 61, 0.22)"
  static BASELINE_LINE = "#55aad7"
  static COMPARE_LINE = "#555"

  // Diagonal-stripe pattern so the baseline's own fill reads as "the plan"
  // (a texture) rather than a third flat color competing with the red/green
  // over/under ribbon drawn on top of it.
  buildCrosshatch(strokeColor) {
    const size = 8
    const patternCanvas = document.createElement("canvas")
    patternCanvas.width = size
    patternCanvas.height = size
    const pctx = patternCanvas.getContext("2d")
    pctx.strokeStyle = strokeColor
    pctx.lineWidth = 1.25
    pctx.beginPath()
    pctx.moveTo(0, size)
    pctx.lineTo(size, 0)
    pctx.stroke()
    return this.canvasTarget.getContext("2d").createPattern(patternCanvas, "repeat")
  }

  // A segment can only be classified as one solid color if it never changes
  // sign. Two-point-per-segment classification (endpoints only) fails
  // exactly when a segment is above at one end and below at the other --
  // the whole span got one color, in effect rounding away the crossing. The
  // fix is to insert a real point at the true crossing (found by linear
  // interpolation) so every resulting segment is single-signed by
  // construction; classifying it is then just "which sign is it."
  buildCrossingAwarePoints(baseline, compare) {
    const basePoints = [{ x: 0, y: baseline[0] }]
    const comparePoints = [{ x: 0, y: compare[0] }]
    const segmentOver = []

    for (let i = 0; i < baseline.length - 1; i++) {
      const diffStart = compare[i] - baseline[i]
      const diffEnd = compare[i + 1] - baseline[i + 1]

      if (diffStart !== 0 && diffEnd !== 0 && (diffStart > 0) !== (diffEnd > 0)) {
        const t = diffStart / (diffStart - diffEnd)
        const crossingX = i + t
        const crossingY = baseline[i] + t * (baseline[i + 1] - baseline[i])
        basePoints.push({ x: crossingX, y: crossingY })
        comparePoints.push({ x: crossingX, y: crossingY })
        segmentOver.push(diffStart > 0)
        segmentOver.push(diffEnd > 0)
      } else {
        segmentOver.push(diffEnd >= 0)
      }

      basePoints.push({ x: i + 1, y: baseline[i + 1] })
      comparePoints.push({ x: i + 1, y: compare[i + 1] })
    }

    return { basePoints, comparePoints, segmentOver }
  }

  connect() {
    const labels = this.labelsValue
    const { basePoints, comparePoints, segmentOver } =
      this.buildCrossingAwarePoints(this.baselineDataValue, this.compareDataValue)
    const tickLabel = (value) => (Number.isInteger(value) ? labels[value] : undefined)

    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: {
        datasets: [
          {
            label: this.baselineLabelValue,
            data: basePoints,
            borderColor: this.constructor.BASELINE_LINE,
            backgroundColor: this.buildCrosshatch(this.constructor.BASELINE_LINE),
            borderWidth: 2,
            pointRadius: (ctx) => (Number.isInteger(ctx.parsed?.x) ? 2 : 0),
            pointHoverRadius: 4,
            pointBackgroundColor: this.constructor.BASELINE_LINE,
            tension: 0,
            fill: true,
            order: 2,
          },
          {
            label: this.compareLabelValue,
            data: comparePoints,
            borderColor: this.constructor.COMPARE_LINE,
            borderWidth: 2,
            pointRadius: (ctx) => (Number.isInteger(ctx.parsed?.x) ? 2 : 0),
            pointHoverRadius: 4,
            pointBackgroundColor: this.constructor.COMPARE_LINE,
            tension: 0,
            fill: { target: 0 },
            segment: {
              backgroundColor: (ctx) =>
                segmentOver[ctx.p0DataIndex] ? this.constructor.OVER_FILL : this.constructor.SHORT_FILL,
            },
            order: 1,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        parsing: false,
        plugins: {
          legend: { display: true, position: "bottom" },
          tooltip: {
            filter: (item) => Number.isInteger(item.parsed.x),
          },
        },
        scales: {
          x: {
            type: "linear",
            min: 0,
            max: labels.length - 1,
            ticks: { stepSize: 1, callback: tickLabel },
          },
          y: { beginAtZero: true, ticks: { precision: 0 } },
        },
      },
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
