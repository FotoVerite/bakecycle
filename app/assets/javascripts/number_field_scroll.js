// Stops mouse-wheel scrolling from silently changing `<input type="number">`
// values. A focused number input treats a wheel event over it as an
// increment/decrement, so on the order form -- where clicking a day cell also
// selects its contents (`focus->order-form#selectContents`) -- scrolling the
// page while a cell is selected quietly rewrites the quantity. Nothing about
// the page moves to indicate it happened, which makes it a silent order-entry
// corruption bug rather than a visible annoyance.
//
// Blurring on wheel (rather than `preventDefault()`) is deliberate: cancelling
// the event would also cancel the page scroll whenever the cursor happens to
// sit over a number field, which is a worse trade. Blurring first means the
// field isn't focused by the time the browser applies its default action, so
// the value is left alone and the page still scrolls normally. Losing focus is
// the correct outcome anyway -- the user is scrolling away from the field.
//
// Registered once at import on `document`, so it survives Turbo navigations
// and covers every number field in the app (orders, shipments, recipes,
// products, buy orders), not just the ones that prompted it.
function isNumberInput(element) {
  return element instanceof HTMLInputElement && element.type === "number"
}

document.addEventListener("wheel", function(event) {
  const active = document.activeElement
  if (!isNumberInput(active)) return
  // Only when the wheel is actually over the focused field -- that's the only
  // case the browser would have stepped the value. An <input> has no children,
  // so the wheel target is the element itself.
  if (event.target !== active) return

  active.blur()
}, { capture: true, passive: true })
