const DATE_FIELD_SELECTOR = 'input.js-datepicker'

function browserSupportsDateInputs() {
  const input = document.createElement('input')
  input.setAttribute('type', 'date')
  return input.type === 'date'
}

const supportsNativeDateInputs = browserSupportsDateInputs()

function enhanceDateField(input) {
  if (input.dataset.datepickerEnhanced === 'true') return

  input.dataset.datepickerEnhanced = 'true'
  input.placeholder = input.placeholder || 'YYYY-MM-DD'
  input.autocomplete = input.autocomplete || 'off'

  if (supportsNativeDateInputs) {
    input.type = 'date'
  } else {
    input.pattern = '\\d{4}-\\d{2}-\\d{2}'
    input.inputMode = 'numeric'
  }
}

function enhanceDateFields(root = document) {
  root.querySelectorAll(DATE_FIELD_SELECTOR).forEach(enhanceDateField)
}

function openNativePicker(input) {
  if (!supportsNativeDateInputs || typeof input.showPicker !== 'function') return

  try {
    input.showPicker()
  } catch (_error) {
    // Browsers only allow showPicker from certain user gestures.
  }
}

document.addEventListener('DOMContentLoaded', function() {
  enhanceDateFields()
})

document.addEventListener('focusin', function(event) {
  if (!event.target.matches(DATE_FIELD_SELECTOR)) return

  enhanceDateField(event.target)
})

document.addEventListener('click', function(event) {
  if (!event.target.matches(DATE_FIELD_SELECTOR)) return

  enhanceDateField(event.target)
  openNativePicker(event.target)
})

const observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    mutation.addedNodes.forEach(function(node) {
      if (!(node instanceof HTMLElement)) return

      if (node.matches(DATE_FIELD_SELECTOR)) {
        enhanceDateField(node)
      } else {
        enhanceDateFields(node)
      }
    })
  })
})

observer.observe(document.documentElement, { childList: true, subtree: true })
