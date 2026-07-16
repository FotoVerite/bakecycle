// Turbo Stream's "remove" action deletes the target element instantly, with no
// transition. Intercept it globally so any `turbo_stream.remove` response
// (e.g. deleting a row from the duplicate-invoices list) fades the element
// out first, then lets Turbo perform the actual removal once the transition
// finishes.
document.addEventListener("turbo:before-stream-render", function(event) {
  const streamElement = event.target
  if (streamElement.action !== "remove") return

  const performRemoval = event.detail.render
  event.detail.render = function(element) {
    const target = document.getElementById(element.target)
    if (!target) {
      performRemoval(element)
      return
    }

    target.classList.add("turbo-stream-fade-out")

    // `transitionend` bubbles up from *any* descendant's own transition (row
    // action icons/buttons have their own hover/color transitions) -- without
    // filtering to the row's own opacity transition, a child's much shorter
    // transition fires first and cuts the row's fade short, so only its text
    // visibly dims before the row vanishes instantly instead of the whole
    // row fading out smoothly.
    //
    // `transitionend` also never fires at all under `prefers-reduced-motion:
    // reduce` (the CSS sets `transition: none` there), which would otherwise
    // strand the element visibly hidden but never actually removed. A
    // timeout fallback -- slightly longer than the CSS transition --
    // guarantees removal happens either way.
    let removed = false
    const remove = () => {
      if (removed) return
      removed = true
      performRemoval(element)
    }
    target.addEventListener("transitionend", (transitionEvent) => {
      if (transitionEvent.target !== target || transitionEvent.propertyName !== "opacity") return
      remove()
    })
    setTimeout(remove, 300)
  }
})
