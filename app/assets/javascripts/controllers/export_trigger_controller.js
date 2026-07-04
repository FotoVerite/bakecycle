import { Controller } from "@hotwired/stimulus"
import { awaitTurboResponse } from "../turbo_response_await"

// Universal "export started" acknowledgment for every async report/export
// trigger (~30 link/button/form-submit call sites using data-turbo-stream).
// Delegated at the body level so no per-template markup changes are needed --
// a pure CSS overlay (see _buttons.scss) works on <a>, <button>, and
// <input type="submit"> alike without touching their internal markup.
//
// This exists because the tray badge alone is easy to miss: it's off in the
// header, and until now nothing happened at the clicked element itself, so a
// click on a report button deep in a page gave zero acknowledgment.
//
// Links/buttons that carry data-turbo-stream directly are handled on click --
// a click on them *is* the action. Forms carry data-turbo-stream on the
// <form> itself (simple_form_for html: { data: { turbo_stream: true } }), so
// they're handled on "submit" instead: delegating that same attribute to
// "click" fired for *any* click inside the form, including clicking a date
// field to open its picker, which stuck the submit button in a permanent
// loading overlay despite nothing being submitted.
export default class extends Controller {
  click(event) {
    const trigger = event.target.closest('a[data-turbo-stream="true"], button[data-turbo-stream="true"]')
    if (trigger) this.startFeedback(trigger)
  }

  submit(event) {
    if (!event.target.matches('form[data-turbo-stream="true"]')) return

    // A form can hold more than one submit button (e.g. "Daily Totals" /
    // "Weekly Totals" sharing one form) -- event.submitter is the one that
    // was actually pressed. Querying the form for the first [type="submit"]
    // always highlighted the same button regardless of which was clicked.
    const trigger = event.submitter
    if (trigger) this.startFeedback(trigger)
  }

  startFeedback(trigger) {
    if (trigger.classList.contains("is-starting")) return

    trigger.classList.add("is-starting")

    awaitTurboResponse(() => {
      trigger.classList.remove("is-starting")
      trigger.classList.add("is-started")
      setTimeout(() => trigger.classList.remove("is-started"), 1400)
    })
  }
}
