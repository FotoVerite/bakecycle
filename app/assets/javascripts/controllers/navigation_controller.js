import { Controller } from "@hotwired/stimulus"

const EASE_OUT_EXPO = "cubic-bezier(0.22, 1, 0.36, 1)"
const DURATION = 250

export default class extends Controller {
  toggleGroup(event) {
    const summary = event.currentTarget
    const details = summary.closest("details.nav-group")
    const content = details.querySelector(":scope > ul")
    if (!details || !content) return

    event.preventDefault()

    if (details.open) {
      this.collapse(details, content)
      return
    }

    this.element.querySelectorAll("details.nav-group[open]").forEach((group) => {
      if (group !== details) this.collapse(group, group.querySelector(":scope > ul"))
    })

    this.expand(details, content)
  }

  expand(details, content) {
    details.open = true
    this.animate(content, "0px", `${content.scrollHeight}px`)
  }

  collapse(details, content) {
    this.animate(content, `${content.scrollHeight}px`, "0px", () => {
      details.open = false
    })
  }

  animate(content, from, to, onFinish) {
    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    content.style.overflow = "hidden"
    const animation = content.animate(
      { height: [from, to] },
      { duration: reduceMotion ? 0 : DURATION, easing: EASE_OUT_EXPO }
    )

    animation.onfinish = () => {
      content.style.overflow = ""
      content.style.height = ""
      if (onFinish) onFinish()
    }

    return animation
  }

  toggleMenu() {
    const navigation = document.querySelector(".side-navigation")
    if (!navigation) return

    navigation.classList.toggle("is-mobile-open")
  }
}
