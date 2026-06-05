const TIME_FIELD_SELECTOR = 'input.js-timepicker'

function browserSupportsTimeInputs() {
  const input = document.createElement('input')
  input.setAttribute('type', 'time')
  return input.type === 'time'
}

const supportsNativeTimeInputs = browserSupportsTimeInputs()

function padTimePart(value) {
  return value.toString().padStart(2, '0')
}

function normalizeTimeValue(value) {
  if (!value) return value

  const trimmed = value.trim()
  const twentyFourHourMatch = trimmed.match(/^(\d{1,2}):(\d{2})(?::\d{2})?$/)

  if (twentyFourHourMatch) {
    return `${padTimePart(twentyFourHourMatch[1])}:${twentyFourHourMatch[2]}`
  }

  const twelveHourMatch = trimmed.match(/^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)$/i)
  if (!twelveHourMatch) return value

  let hour = parseInt(twelveHourMatch[1], 10)
  const minute = twelveHourMatch[2] || '00'
  const meridian = twelveHourMatch[3].toUpperCase()

  if (meridian === 'AM' && hour === 12) hour = 0
  if (meridian === 'PM' && hour < 12) hour += 12

  return `${padTimePart(hour)}:${minute}`
}

function enhanceTimeField(input) {
  if (input.dataset.timepickerEnhanced === 'true') return

  input.dataset.timepickerEnhanced = 'true'
  input.placeholder = input.placeholder || 'HH:MM'
  input.autocomplete = input.autocomplete || 'off'

  if (supportsNativeTimeInputs) {
    input.value = normalizeTimeValue(input.value)
    input.type = 'time'
    input.step = input.step || '300'
  } else {
    input.pattern = '([01]?\\d|2[0-3]):[0-5]\\d|([1-9]|1[0-2])(:[0-5]\\d)?\\s?(AM|PM|am|pm)'
  }
}

function enhanceTimeFields(root = document) {
  root.querySelectorAll(TIME_FIELD_SELECTOR).forEach(enhanceTimeField)
}

function openNativePicker(input) {
  if (!supportsNativeTimeInputs || typeof input.showPicker !== 'function') return

  try {
    input.showPicker()
  } catch (_error) {
    // Browsers only allow showPicker from certain user gestures.
  }
}

document.addEventListener('DOMContentLoaded', function() {
  enhanceTimeFields()
})

document.addEventListener('focusin', function(event) {
  if (!event.target.matches(TIME_FIELD_SELECTOR)) return

  enhanceTimeField(event.target)
})

document.addEventListener('click', function(event) {
  if (!event.target.matches(TIME_FIELD_SELECTOR)) return

  enhanceTimeField(event.target)
  openNativePicker(event.target)
})

const observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    mutation.addedNodes.forEach(function(node) {
      if (!(node instanceof HTMLElement)) return

      if (node.matches(TIME_FIELD_SELECTOR)) {
        enhanceTimeField(node)
      } else {
        enhanceTimeFields(node)
      }
    })
  })
})

observer.observe(document.documentElement, { childList: true, subtree: true })
