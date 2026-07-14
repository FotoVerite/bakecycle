import { Application } from "@hotwired/stimulus"
import CancellationFormController from "controllers/cancellation_form_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))

function buildFixture() {
  return `
    <form data-controller="cancellation-form">
      <input data-cancellation-form-target="nameFilter">
      <select data-cancellation-form-target="routeFilter"><option value=""></option></select>
      <span data-cancellation-form-target="count"></span>

      <button type="button" data-cancellation-form-target="clientRow"
              data-action="click->cancellation-form#toggleClient"
              data-id="1" data-name="First client" data-route-id="1" data-route-name="Route one"
              data-selected="false" aria-pressed="false">First client</button>
      <button type="button" data-cancellation-form-target="clientRow"
              data-action="click->cancellation-form#toggleClient"
              data-id="2" data-name="Second client" data-route-id="2" data-route-name="Route two"
              data-selected="false" aria-pressed="false">Second client</button>

      <aside data-cancellation-form-target="cart">
        <span data-cancellation-form-target="cartCount">0</span>
        <p data-cancellation-form-target="cartEmpty">No clients selected</p>
        <ul data-cancellation-form-target="cartList" hidden></ul>
        <div data-cancellation-form-target="hiddenInputs"></div>
      </aside>
      <button data-cancellation-form-target="submit" disabled>Preview</button>
    </form>
  `
}

let application

beforeEach(() => {
  application = Application.start()
  application.register("cancellation-form", CancellationFormController)
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

async function mount() {
  document.body.innerHTML = buildFixture()
  await nextTick()
  return application.getControllerForElementAndIdentifier(document.querySelector("form"), "cancellation-form")
}

describe("CancellationFormController", () => {
  it("keeps selected cart entries mounted when another client is selected", async () => {
    await mount()
    const [first, second] = document.querySelectorAll("[data-cancellation-form-target='clientRow']")

    first.click()
    const firstCartItem = document.querySelector(".cancellation-cart-item[data-id='1']")
    second.focus()
    second.click()

    expect(document.querySelector(".cancellation-cart-item[data-id='1']")).toBe(firstCartItem)
    expect(document.activeElement).toBe(second)
    expect(document.querySelectorAll(".cancellation-cart-item")).toHaveLength(2)
  })

  it("removes only the chosen client from the cart", async () => {
    await mount()
    const [first, second] = document.querySelectorAll("[data-cancellation-form-target='clientRow']")

    first.click()
    second.click()
    await nextTick()
    document.querySelector("[aria-label='Remove First client']").click()

    expect(document.querySelector(".cancellation-cart-item[data-id='1']")).toBeNull()
    expect(document.querySelector(".cancellation-cart-item[data-id='2']")).not.toBeNull()
    expect(first.dataset.selected).toBe("false")
    expect(second.dataset.selected).toBe("true")
  })
})
