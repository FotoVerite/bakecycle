function registrationForm() {
  return document.querySelector("#registration-form")
}

function setSubmitting(form, submitting) {
  form.querySelectorAll("button, input[type='submit']").forEach(control => {
    control.disabled = submitting
  })
}

function showStripeError(form, message) {
  const errors = form.querySelector(".payment-errors")
  if (errors) errors.textContent = message
}

function submitWithStripe(event) {
  const form = event.currentTarget
  if (!window.Stripe) {
    event.preventDefault()
    showStripeError(form, "Secure payment services are unavailable. Please refresh and try again.")
    return
  }

  event.preventDefault()
  setSubmitting(form, true)
  showStripeError(form, "")

  const field = name => form.querySelector(`[data-stripe='${name}']`)?.value
  window.Stripe.setPublishableKey(document.querySelector("meta[name='stripe-key']")?.content)
  window.Stripe.card.createToken({
    number: field("number"),
    cvc: field("cvc"),
    exp_month: field("exp-month"),
    exp_year: field("exp-year"),
    address_zip: field("address_zip")
  }, (_status, response) => {
    if (response.error) {
      showStripeError(form, response.error.message)
      setSubmitting(form, false)
      return
    }

    const token = document.createElement("input")
    token.type = "hidden"
    token.name = "registration[stripe_token]"
    token.value = response.id
    form.append(token)
    form.submit()
  })
}

function connectStripeRegistration() {
  const form = registrationForm()
  if (form && !form.dataset.stripeRegistrationConnected) {
    form.dataset.stripeRegistrationConnected = "true"
    form.addEventListener("submit", submitWithStripe)
  }
}

document.addEventListener("turbo:load", connectStripeRegistration)
document.addEventListener("DOMContentLoaded", connectStripeRegistration)
