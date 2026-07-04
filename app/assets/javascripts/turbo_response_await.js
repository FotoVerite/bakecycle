// Waits for the next `turbo:before-fetch-response` event (a Turbo request
// settling) or a fixed timeout, whichever comes first, then invokes
// `callback` exactly once. Returns a `cancel()` function to remove the
// pending listener/timeout early (e.g. on Stimulus disconnect).
export function awaitTurboResponse(callback, { timeoutMs = 8000 } = {}) {
  const finish = () => {
    cancel()
    callback()
  }

  document.addEventListener("turbo:before-fetch-response", finish, { once: true })
  const timeout = setTimeout(finish, timeoutMs)

  function cancel() {
    document.removeEventListener("turbo:before-fetch-response", finish)
    clearTimeout(timeout)
  }

  return cancel
}
