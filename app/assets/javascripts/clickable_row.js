// Whole-row navigation for `tr.js-clickable-row[href]` tables (orders, invoices,
// clients, products, recipes, etc). Previously implemented in
// jquery-components/clickable-row.js, but that file is only reachable through the
// Sprockets `//= require` manifest in application.js -- and this app now runs
// Propshaft only (no sprockets-rails gem), which doesn't process directive
// comments, so that manifest ships as an empty file and jQuery is never loaded.
// Reimplemented here in vanilla JS so it's actually bundled (via app.js -> esbuild).
function isInteractiveTarget(target) {
  return target.closest("a, button, input, select, textarea, label") !== null
}

function navigateRow(row) {
  window.document.location = row.dataset.href || row.getAttribute("href")
}

document.addEventListener("click", function(event) {
  const row = event.target.closest(".js-clickable-row")
  if (!row || isInteractiveTarget(event.target)) return

  navigateRow(row)
})

document.addEventListener("keydown", function(event) {
  if (event.key !== "Enter") return

  const row = event.target.closest(".js-clickable-row")
  if (!row || isInteractiveTarget(event.target)) return

  event.preventDefault()
  navigateRow(row)
})

function makeRowsFocusable() {
  document.querySelectorAll(".js-clickable-row:not([tabindex])").forEach(function(row) {
    row.setAttribute("tabindex", "0")
    row.setAttribute("role", "link")
  })
}

document.addEventListener("DOMContentLoaded", makeRowsFocusable)
document.addEventListener("turbo:load", makeRowsFocusable)
